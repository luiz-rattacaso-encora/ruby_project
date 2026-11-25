require "test_helper"
require_relative "support/org_setup"

class AuthEndpointsTest < ActionDispatch::IntegrationTest
  include OrgSetup
  include ActionMailer::TestHelper

  setup { build_org }

  # Every page except login and password reset requires a session.
  PROTECTED_GETS = %w[
    / /employees /employees/all /employees/new /teams /teams/new
    /memberships /memberships/new /announcements /announcements/new
  ].freeze

  PROTECTED_GETS.each do |path|
    test "GET #{path} redirects to login when signed out" do
      get path
      assert_redirected_to new_session_path
    end
  end

  test "member pages redirect to login when signed out" do
    [ employee_path(@worker), "/employees/#{@worker.id}/hierarchy", edit_employee_path(@worker),
      team_path(@alpha), team_weekly_updates_path(@alpha), weekly_update_path(@update),
      announcement_path(@announcement), membership_path(Membership.first) ].each do |path|
      get path
      assert_redirected_to new_session_path, "#{path} should require login"
    end
  end

  test "writes are rejected when signed out" do
    assert_no_difference -> { Team.count } do
      post teams_path, params: { team: { name: "X", description: "Y", technologies: "Z" } }
    end
    assert_redirected_to new_session_path

    assert_no_difference -> { Employee.count } do
      delete employee_path(@worker)
    end
    assert_redirected_to new_session_path
  end

  test "login page renders" do
    get new_session_path
    assert_response :success
  end

  test "login with valid credentials then logout" do
    post session_path, params: { email_address: @worker.user.email_address, password: PASSWORD }
    assert_redirected_to root_path
    assert cookies[:session_id].present?

    get root_path
    assert_response :success

    delete session_path
    assert_redirected_to new_session_path
    get root_path
    assert_redirected_to new_session_path
  end

  test "login email is case and whitespace insensitive" do
    post session_path, params: { email_address: "  #{@worker.user.email_address.upcase} ", password: PASSWORD }
    assert_redirected_to root_path
  end

  test "login with wrong password is rejected" do
    post session_path, params: { email_address: @worker.user.email_address, password: "nope" }
    assert_redirected_to new_session_path
    assert cookies[:session_id].blank?
  end

  test "after login the user goes back to the page they asked for" do
    get announcements_path
    post session_path, params: { email_address: @worker.user.email_address, password: PASSWORD }
    assert_redirected_to announcements_url
  end

  test "password reset request sends an email only for known addresses" do
    get new_password_path
    assert_response :success

    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @worker.user ] do
      post passwords_path, params: { email_address: @worker.user.email_address }
    end
    assert_redirected_to new_session_path

    assert_enqueued_emails 0 do
      post passwords_path, params: { email_address: "nobody@example.com" }
    end
    assert_redirected_to new_session_path
  end

  test "password reset with a valid token changes the password and ends sessions" do
    user = @worker.user
    user.sessions.create!
    token = user.password_reset_token

    get edit_password_path(token)
    assert_response :success

    put password_path(token), params: { password: "NewPass456!", password_confirmation: "NewPass456!" }
    assert_redirected_to new_session_path
    assert_equal 0, user.sessions.count

    post session_path, params: { email_address: user.email_address, password: "NewPass456!" }
    assert_redirected_to root_path
  end

  test "password reset with mismatched confirmation keeps the old password" do
    token = @worker.user.password_reset_token
    put password_path(token), params: { password: "a", password_confirmation: "b" }
    assert_redirected_to edit_password_path(token)
    assert @worker.user.reload.authenticate(PASSWORD)
  end

  test "password reset with an invalid token is refused" do
    get edit_password_path("bogus")
    assert_redirected_to new_password_path
  end

  test "home shows the signed-in employee" do
    login(@worker)
    get root_path
    assert_response :success
    assert_includes response.body, "Worker"
  end
end
