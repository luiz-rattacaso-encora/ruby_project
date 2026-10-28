class EmployeePolicy
  def initialize(current_user, employee)
    @current_user = current_user
    @employee     = employee

    @current_employee = Employee.find_by(user_id: current_user&.id) if current_user
  end

  def own_profile?
    return false unless @current_user && @employee.user_id

    @employee.user_id == @current_user.id
  end

  def is_manager_of?
    return false unless @current_employee && @employee.manager_id

    @employee.manager_id == @current_employee.id
  end

  def can_update?
    own_profile? || is_manager_of?
  end
end
