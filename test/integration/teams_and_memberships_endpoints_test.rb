require "test_helper"
require_relative "support/org_setup"

class TeamsAndMembershipsEndpointsTest < ActionDispatch::IntegrationTest
  include OrgSetup

  setup do
    build_org
    login(@boss)
  end

  # ── Teams ────────────────────────────────────────────────────────────────
  test "teams index lists teams and filters by name" do
    get teams_path
    assert_response :success
    assert_includes response.body, @alpha.name

    get teams_path, params: { search_name: "Beta" }, headers: JSON_HEADERS
    assert_response :ok
    assert_equal [ @beta.id ], json.map { |t| t["id"] }
  end

  test "team show as HTML and JSON" do
    get team_path(@alpha)
    assert_response :success

    get team_path(@alpha), headers: JSON_HEADERS
    assert_response :ok
    assert_equal @alpha.name, json["name"]
    assert_equal %w[Ruby Rails], json["technologies"]
  end

  test "team create, update and destroy via JSON" do
    post teams_path, headers: JSON_HEADERS, params: { team: { name: "Gamma", description: "G", technologies: "Go" } }
    assert_response :created
    gamma = Team.find(json["id"])

    patch team_path(gamma), headers: JSON_HEADERS, params: { team: { description: "Gamma v2" } }
    assert_response :ok
    assert_equal "Gamma v2", gamma.reload.description

    delete team_path(gamma), headers: JSON_HEADERS
    assert_response :no_content
    assert_not Team.exists?(gamma.id)
  end

  test "team validations: name, description, technologies required and name unique" do
    post teams_path, headers: JSON_HEADERS, params: { team: { name: "", description: "", technologies: "" } }
    assert_response :unprocessable_content
    assert_equal %w[description name technologies], json.keys.sort

    post teams_path, headers: JSON_HEADERS, params: { team: { name: @alpha.name, description: "dup", technologies: "x" } }
    assert_response :unprocessable_content
    assert json["name"].present?
  end

  test "deleting a team removes its memberships and weekly updates" do
    team = Team.create!(name: "Temp", description: "t", technologies: %w[x])
    Membership.create!(employee: @worker, team: team)
    WeeklyUpdate.create!(team: team, author: @worker, content: "c")
    assert_difference -> { Membership.count } => -1, -> { WeeklyUpdate.count } => -1 do
      delete team_path(team)
    end
  end

  # ── Memberships ──────────────────────────────────────────────────────────
  test "memberships index shows only active memberships and filters by employee name" do
    Membership.create!(employee: @outsider, team: @beta, finished_at: 1.day.ago)

    get memberships_path
    assert_response :success

    get memberships_path, headers: JSON_HEADERS
    assert_equal Membership.where(finished_at: nil).count, json.size

    get memberships_path, params: { search_name: "Worker" }, headers: JSON_HEADERS
    assert_equal [ @worker.id ], json.map { |m| m["employee_id"] }
  end

  test "membership new, show and edit render" do
    membership = @worker.memberships.first
    get new_membership_path
    assert_response :success
    get membership_path(membership)
    assert_response :success
    get edit_membership_path(membership)
    assert_response :success
  end

  test "create a membership and reject a duplicate active one" do
    assert_difference -> { Membership.count } => 1 do
      post memberships_path, params: { membership: { employee_id: @outsider.id, team_id: @alpha.id } }
    end
    assert_redirected_to memberships_path

    assert_no_difference -> { Membership.count } do
      post memberships_path, headers: JSON_HEADERS, params: { membership: { employee_id: @outsider.id, team_id: @alpha.id } }
    end
    assert_response :unprocessable_entity
  end

  test "after finishing a membership the employee can join the same team again" do
    membership = @worker.memberships.first
    delete membership_path(membership)
    assert_redirected_to memberships_path
    assert membership.reload.finished_at.present?
    assert_not @worker.active_teams.include?(@alpha)

    post memberships_path, headers: JSON_HEADERS, params: { membership: { employee_id: @worker.id, team_id: @alpha.id } }
    assert_response :created
  end

  test "update moves a membership to another team" do
    membership = @worker.memberships.first
    patch membership_path(membership), params: { membership: { team_id: @beta.id } }
    assert_redirected_to employee_path(@worker)
    assert_equal @beta, membership.reload.team
  end

  test "unknown membership is a 404 in JSON" do
    get membership_path(id: 0), headers: JSON_HEADERS
    assert_response :not_found
  end
end
