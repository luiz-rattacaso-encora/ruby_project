require "test_helper"
require_relative "support/org_setup"

class EmployeesEndpointsTest < ActionDispatch::IntegrationTest
  include OrgSetup

  setup { build_org }

  # ── Reading ──────────────────────────────────────────────────────────────
  test "index shows the signed-in manager's direct reports" do
    login(@boss)
    get employees_path
    assert_response :success
    assert_includes response.body, "Worker Person"
    assert_includes response.body, "Lead Person"
  end

  test "index as JSON returns the signed-in employee" do
    login(@worker)
    get employees_path, headers: JSON_HEADERS
    assert_response :ok
    assert_equal @worker.id, json["id"]
  end

  test "index redirects home when the user has no employee profile" do
    user = User.create!(email_address: "ghost@example.com", password: PASSWORD)
    sign_in_as(user)
    get employees_path
    assert_redirected_to root_path

    get employees_path, headers: JSON_HEADERS
    assert_response :not_found
  end

  test "all lists every employee and filters by name" do
    login(@worker)
    get "/employees/all"
    assert_response :success
    %w[Boss Lead Worker Outsider].each { |name| assert_includes response.body, "#{name} Person" }

    get "/employees/all", params: { search_name: "Lead Per" }, headers: JSON_HEADERS
    assert_response :ok
    assert_equal [ @lead.id ], json.map { |e| e["id"] }
  end

  test "show and hierarchy render the reporting chain" do
    login(@worker)
    get employee_path(@lead)
    assert_response :success
    assert_includes response.body, "Lead Person"

    get "/employees/#{@worker.id}/hierarchy"
    assert_response :success
    assert_includes response.body, "Boss Person (Director)"
    assert_equal [ @boss ], @worker.reports_to
  end

  test "show as JSON does not expose password data" do
    login(@worker)
    get employee_path(@lead), headers: JSON_HEADERS
    assert_response :ok
    assert_equal "Lead", json["first_name"]
    refute_match(/password/i, response.body)
  end

  test "show of an unknown employee is a 404" do
    login(@worker)
    get employee_path(id: 0), headers: JSON_HEADERS
    assert_response :not_found
  end

  # ── Creating (managers only) ─────────────────────────────────────────────
  test "manager can open the new form and create an employee with a user" do
    login(@boss)
    get new_employee_path
    assert_response :success

    assert_difference -> { Employee.count } => 1, -> { User.count } => 1 do
      post employees_path, params: { employee: {
        first_name: "New", last_name: "Hire", role: "QA", manager_id: @boss.id,
        user_attributes: { email_address: "new.hire@example.com", password: "Pass1234!", password_confirmation: "Pass1234!" }
      } }
    end
    assert_redirected_to "/employees"
    hire = Employee.last
    assert_equal @boss, hire.manager
    assert hire.user.authenticate("Pass1234!")
  end

  test "create with missing fields re-renders the form" do
    login(@boss)
    assert_no_difference -> { Employee.count } do
      post employees_path, params: { employee: { first_name: "", last_name: "", role: "", user_attributes: { email_address: "x@example.com" } } }
    end
    assert_response :unprocessable_entity
  end

  test "create via JSON returns 201 and validation errors as 422" do
    login(@boss)
    post employees_path, headers: JSON_HEADERS, params: { employee: {
      first_name: "Api", last_name: "Hire", role: "Ops", user_attributes: { email_address: "api@example.com", password: "Pass1234!" }
    } }
    assert_response :created

    post employees_path, headers: JSON_HEADERS, params: { employee: { first_name: "", user_attributes: { email_address: "api@example.com" } } }
    assert_response :unprocessable_entity
  end

  test "non-manager cannot open the new form, create or delete" do
    login(@worker)
    get new_employee_path
    assert_redirected_to root_path

    assert_no_difference -> { Employee.count } do
      post employees_path, headers: JSON_HEADERS, params: { employee: { first_name: "X", last_name: "Y", role: "Z", user_attributes: { email_address: "z@example.com" } } }
    end
    assert_response :forbidden

    assert_no_difference -> { Employee.count } do
      delete employee_path(@outsider), headers: JSON_HEADERS
    end
    assert_response :forbidden
  end

  # ── Updating (self or direct manager) ────────────────────────────────────
  test "employee can edit and update their own profile" do
    login(@worker)
    get edit_employee_path(@worker)
    assert_response :success

    patch employee_path(@worker), params: { employee: { role: "Senior Developer" } }
    assert_redirected_to "/employees/#{@worker.id}"
    assert_equal "Senior Developer", @worker.reload.role
  end

  test "direct manager can update a report" do
    login(@boss)
    patch employee_path(@worker), headers: JSON_HEADERS, params: { employee: { role: "Staff Developer" } }
    assert_response :ok
    assert_equal "Staff Developer", @worker.reload.role
  end

  test "update with invalid data returns 422" do
    login(@worker)
    patch employee_path(@worker), headers: JSON_HEADERS, params: { employee: { first_name: "" } }
    assert_response :unprocessable_entity
  end

  test "a peer or a non-direct manager cannot update someone else" do
    login(@lead) # manager, but not the worker's manager
    patch employee_path(@worker), headers: JSON_HEADERS, params: { employee: { role: "Hacked" } }
    assert_response :forbidden

    login(@outsider)
    get edit_employee_path(@worker)
    assert_redirected_to root_path
    assert_equal "Developer", @worker.reload.role
  end

  # ── Deleting ─────────────────────────────────────────────────────────────
  test "manager can delete an employee without reports, and the user goes with it" do
    login(@boss)
    user_id = @outsider.user_id
    assert_difference -> { Employee.count } => -1 do
      delete employee_path(@outsider)
    end
    assert_redirected_to "/employees"
    assert_not User.exists?(user_id)
  end
end
