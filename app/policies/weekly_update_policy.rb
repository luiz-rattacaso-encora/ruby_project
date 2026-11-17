class WeeklyUpdatePolicy
  def initialize(current_user, target)
    @current_user = current_user
    @target = target
    @current_employee = Employee.find_by(user_id: current_user&.id) if current_user
  end

  def team
    if @target.is_a?(Team)
      @target
    elsif @target.respond_to?(:team)
      @target.team
    end
  end

  def member_of_team?
    return false unless @current_employee && team
    team.memberships.where(finished_at: nil).exists?(employee_id: @current_employee.id)
  end

  def author_of_update?
    return false unless @current_employee && @target.is_a?(WeeklyUpdate)
    @target.author == @current_employee
  end

  def can_view?
    member_of_team?
  end

  def can_create?
    member_of_team?
  end

  def can_modify?
    author_of_update?
  end
end
