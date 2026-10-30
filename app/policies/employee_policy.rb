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

  def is_manager?
    !!@current_employee&.is_manager
  end

  def is_direct_manager_of?(other_employee)
    return false unless @current_employee && other_employee&.manager_id

    other_employee.manager_id == @current_employee.id
  end

  def can_update?
    own_profile? || is_direct_manager_of?(@employee)
  end

  def can_create_and_destroy?
    is_manager?
  end
end
