require "test_helper"
require_relative "support/org_setup"

class AnnouncementsAndUpdatesEndpointsTest < ActionDispatch::IntegrationTest
  include OrgSetup

  setup { build_org }

  # ── Announcements ────────────────────────────────────────────────────────
  test "any employee can list and view announcements" do
    login(@outsider)
    get announcements_path
    assert_response :success
    assert_includes response.body, "Release"

    get announcement_path(@announcement), headers: JSON_HEADERS
    assert_response :ok
    assert_equal "Release", json["title"]
  end

  test "announcements can be filtered by team" do
    Announcement.create!(author: @boss, team: @beta, title: "Beta news", content: "b")
    login(@worker)
    get announcements_path, params: { team_id: @beta.id }, headers: JSON_HEADERS
    assert_equal [ "Beta news" ], json.map { |a| a["title"] }
  end

  test "users without an employee profile are sent home" do
    sign_in_as(User.create!(email_address: "ghost@example.com", password: PASSWORD))
    get announcements_path
    assert_redirected_to root_path
  end

  test "team member creates, edits and deletes their own announcement" do
    login(@worker)
    get new_announcement_path
    assert_response :success

    assert_difference -> { Announcement.count } => 1 do
      post announcements_path, params: { announcement: { title: "Demo", content: "Friday", team_id: @alpha.id } }
    end
    assert_redirected_to announcements_path
    created = Announcement.last
    assert_equal @worker, created.author

    get edit_announcement_path(created)
    assert_response :success
    patch announcement_path(created), headers: JSON_HEADERS, params: { announcement: { title: "Demo day" } }
    assert_response :ok
    assert_equal "Demo day", created.reload.title

    delete announcement_path(created), headers: JSON_HEADERS
    assert_response :no_content
  end

  test "announcement validation errors return 422" do
    login(@worker)
    post announcements_path, headers: JSON_HEADERS, params: { announcement: { title: "", content: "", team_id: @alpha.id } }
    assert_response :unprocessable_entity
  end

  test "employee without an active team cannot open the form or post" do
    login(@outsider)
    get new_announcement_path
    assert_redirected_to announcements_path

    post announcements_path, headers: JSON_HEADERS, params: { announcement: { title: "t", content: "c", team_id: @alpha.id } }
    assert_response :forbidden
  end

  test "cannot post to a team you are not in" do
    login(@worker)
    assert_no_difference -> { Announcement.count } do
      post announcements_path, headers: JSON_HEADERS, params: { announcement: { title: "t", content: "c", team_id: @beta.id } }
    end
    assert_response :forbidden
  end

  test "only the author can edit or delete an announcement" do
    login(@lead) # same team, not the author
    patch announcement_path(@announcement), headers: JSON_HEADERS, params: { announcement: { title: "x" } }
    assert_response :forbidden
    delete announcement_path(@announcement), headers: JSON_HEADERS
    assert_response :forbidden
    assert Announcement.exists?(@announcement.id)
  end

  test "author who left the team can no longer edit its announcement" do
    @worker.memberships.update_all(finished_at: Time.current)
    login(@worker)
    patch announcement_path(@announcement), headers: JSON_HEADERS, params: { announcement: { title: "x" } }
    assert_response :forbidden
  end

  test "unknown announcement redirects with a 404 in JSON" do
    login(@worker)
    get announcement_path(id: 0), headers: JSON_HEADERS
    assert_response :not_found
  end

  # ── Weekly updates ───────────────────────────────────────────────────────
  test "team member lists this week's updates and filters by status" do
    WeeklyUpdate.create!(team: @alpha, author: @lead, content: "Draft idea", status: "draft")
    login(@lead)
    get team_weekly_updates_path(@alpha)
    assert_response :success
    assert_includes response.body, "Shipped login"

    get team_weekly_updates_path(@alpha), params: { status: "draft" }, headers: JSON_HEADERS
    assert_equal [ "Draft idea" ], json.map { |u| u["content"] }
  end

  test "weekly updates can be filtered by author name" do
    WeeklyUpdate.create!(team: @alpha, author: @lead, content: "Lead note")
    login(@worker)
    get team_weekly_updates_path(@alpha), params: { author_name: "Lead" }, headers: JSON_HEADERS
    assert_response :ok
    assert_equal [ "Lead note" ], json.map { |u| u["content"] }
  end

  test "non-member cannot list, open or create updates for a team" do
    login(@outsider)
    get team_weekly_updates_path(@alpha), headers: JSON_HEADERS
    assert_response :forbidden
    get weekly_update_path(@update), headers: JSON_HEADERS
    assert_response :forbidden
    post team_weekly_updates_path(@alpha), headers: JSON_HEADERS, params: { weekly_update: { content: "x" } }
    assert_response :forbidden
  end

  test "member creates an update; status defaults to draft and publishing sets the date" do
    login(@lead)
    get new_team_weekly_update_path(@alpha)
    assert_response :success

    post team_weekly_updates_path(@alpha), headers: JSON_HEADERS, params: { weekly_update: { content: "Planning" } }
    assert_response :created
    created = WeeklyUpdate.find(json["id"])
    assert created.draft?
    assert_nil created.published_date
    assert_equal @lead, created.author

    patch weekly_update_path(created), headers: JSON_HEADERS, params: { weekly_update: { status: "published" } }
    assert_response :ok
    assert created.reload.published_date.present?
  end

  test "weekly update with empty content is rejected" do
    login(@lead)
    post team_weekly_updates_path(@alpha), headers: JSON_HEADERS, params: { weekly_update: { content: "" } }
    assert_response :unprocessable_entity
  end

  test "only the author can edit or delete a weekly update" do
    login(@lead)
    get edit_weekly_update_path(@update)
    assert_redirected_to root_path
    delete weekly_update_path(@update), headers: JSON_HEADERS
    assert_response :forbidden

    login(@worker)
    get edit_weekly_update_path(@update)
    assert_response :success
    delete weekly_update_path(@update)
    assert_redirected_to team_weekly_updates_path(@alpha)
    assert_not WeeklyUpdate.exists?(@update.id)
  end

  test "unknown team or update is handled" do
    login(@worker)
    get team_weekly_updates_path(team_id: 0), headers: JSON_HEADERS
    assert_response :not_found
    get weekly_update_path(id: 0), headers: JSON_HEADERS
    assert_response :not_found
  end
end
