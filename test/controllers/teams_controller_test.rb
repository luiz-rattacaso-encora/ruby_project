require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get teams_url
    assert_response :success
  end

  test "should get new" do
    get new_team_url
    assert_response :success
  end

  test "should create team" do
    assert_difference("Team.count") do
      post teams_url, params: { team: {
          name: "Valid Team Name #{SecureRandom.hex(4)}",
          description: "This is a valid and sufficiently long team description.",
          technologies: "Ruby, Rails, Postgres"
        }
      }
    end

    assert_redirected_to team_url(Team.last)
  end

  test "should show team" do
    get team_url(@team)
    assert_response :success
  end

  test "should get edit" do
    get edit_team_url(@team)
    assert_response :success
  end

  test "should update team" do
    patch team_url(@team), params: { team: {
        name: "Completely New Valid Name",
        description: "Updated description that matches any length validation rules.",
        technologies: "Ruby, React"
      }
    }
    assert_redirected_to team_url(@team)
  end

  test "should destroy team" do
    assert_difference("Team.count", -1) do
      delete team_url(@team)
    end

    assert_redirected_to teams_url
  end
end
