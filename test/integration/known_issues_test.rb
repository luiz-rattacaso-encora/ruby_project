require "test_helper"
require_relative "support/org_setup"

# Each test here describes the CORRECT behaviour for a bug found in review.
# They fail on the current code, so they are skipped by default to keep CI green.
# Run them with:
#
#   KNOWN_BUGS=1 bin/rails test test/integration/known_issues_test.rb
#
# When you fix a bug, run its test with KNOWN_BUGS=1, and once it passes move it
# to the matching *_endpoints_test.rb file so it always runs.
class KnownIssuesTest < ActionDispatch::IntegrationTest
  include OrgSetup

  setup do
    skip "Known bug (see the test name). Run with KNOWN_BUGS=1" unless ENV["KNOWN_BUGS"] == "1"
    build_org
  end

  # ── Setup ────────────────────────────────────────────────────────────────
  test "db/seeds.rb runs on an empty database (README setup step)" do
    assert_nothing_raised { load Rails.root.join("db/seeds.rb") }
    assert User.exists?(email_address: "michael@michael.com")
  end

  # ── Authorization ────────────────────────────────────────────────────────
  test "an employee cannot promote themselves to manager" do
    login(@worker)
    patch employee_path(@worker), headers: JSON_HEADERS, params: { employee: { is_manager: true } }
    assert_not @worker.reload.is_manager, "worker became a manager by editing their own profile"
  end

  test "an employee cannot move their profile to another user account" do
    login(@worker)
    patch employee_path(@worker), headers: JSON_HEADERS, params: { employee: { user_id: @boss.user_id } }
    assert_not_equal @boss.user_id, @worker.reload.user_id
  end

  test "an employee cannot change who their manager is" do
    login(@worker)
    patch employee_path(@worker), headers: JSON_HEADERS, params: { employee: { manager_id: @lead.id } }
    assert_equal @boss, @worker.reload.manager
  end

  test "a non-manager cannot create or delete teams" do
    login(@outsider)
    assert_no_difference -> { Team.count } do
      post teams_path, headers: JSON_HEADERS, params: { team: { name: "Rogue", description: "d", technologies: "x" } }
    end
    assert_no_difference -> { Team.count } do
      delete team_path(@beta), headers: JSON_HEADERS
    end
  end

  test "a non-manager cannot add themselves to a team" do
    login(@outsider)
    assert_no_difference -> { Membership.count } do
      post memberships_path, headers: JSON_HEADERS, params: { membership: { employee_id: @outsider.id, team_id: @alpha.id } }
    end
  end

  test "a non-manager cannot end someone else's membership" do
    login(@outsider)
    membership = @lead.memberships.first
    delete membership_path(membership), headers: JSON_HEADERS
    assert_nil membership.reload.finished_at
  end

  test "a former team member can no longer read the team's weekly updates" do
    @worker.memberships.update_all(finished_at: Time.current)
    login(@worker)
    get team_weekly_updates_path(@alpha), headers: JSON_HEADERS
    assert_response :forbidden
  end

  # ── CSRF ─────────────────────────────────────────────────────────────────
  test "HTML form posts without a CSRF token are rejected" do
    with_forgery_protection do
      login(@boss)
      assert_no_difference -> { Team.count } do
        post teams_path, params: { team: { name: "CSRF", description: "d", technologies: "x" } }
      end
      assert_no_difference -> { Employee.count } do
        delete employee_path(@outsider)
      end
    end
  end

  # ── Accounts ─────────────────────────────────────────────────────────────
  test "a new employee created without a password cannot log in with their first name" do
    login(@boss)
    post employees_path, headers: JSON_HEADERS, params: { employee: {
      first_name: "Default", last_name: "Pass", role: "r", user_attributes: { email_address: "default@example.com" }
    } }
    sign_out
    post session_path, params: { email_address: "default@example.com", password: "Default" }
    assert_redirected_to new_session_path, "first name works as the password"
  end

  # ── Bugs ─────────────────────────────────────────────────────────────────
  test "announcements can be filtered by author name (ILIKE is not valid MySQL)" do
    login(@worker)
    get announcements_path, params: { author_name: "Worker" }, headers: JSON_HEADERS
    assert_response :ok
    assert_equal [ "Release" ], json.map { |a| a["title"] }
  end

  test "weekly updates index only shows this week's updates" do
    old = WeeklyUpdate.create!(team: @alpha, author: @worker, content: "Old news")
    old.update_columns(updated_at: 3.months.ago)
    login(@worker)
    get team_weekly_updates_path(@alpha), headers: JSON_HEADERS
    assert_not_includes json.map { |u| u["content"] }, "Old news"
  end

  test "a team that has announcements can be deleted" do
    login(@boss)
    delete team_path(@alpha), headers: JSON_HEADERS
    assert_response :no_content
  end

  test "a manager who has direct reports can be deleted" do
    login(@boss)
    manager = hire("Mid", "Manager", "Manager", manager: true, reports_to: @boss)
    hire("Report", "Person", "Dev", reports_to: manager)
    delete employee_path(manager), headers: JSON_HEADERS
    assert_response :no_content
  end

  test "team technologies from the form are stored as a list" do
    login(@boss)
    post teams_path, headers: JSON_HEADERS, params: { team: { name: "Gamma", description: "G", technologies: "Ruby, Rails" } }
    assert_equal %w[Ruby Rails], Team.find_by(name: "Gamma").technologies
  end

  private

  # Forgery protection is off in the test environment; turn it on for one block.
  def with_forgery_protection
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end
end
