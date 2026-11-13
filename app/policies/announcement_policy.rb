class AnnouncementPolicy
  def initialize(user, announcement: nil, team: nil)
    @user = user
    @announcement = announcement
    @team = team
  end

  def can_view?
    current_employee.present?
  end

  def can_access_new_form?
    return false if current_employee.nil?

    Membership.exists?(employee_id: current_employee.id, finished_at: nil)
  end

  def can_create_for_team?
    return false if current_employee.nil?
    return false if @team.nil?

    Membership.exists?(
      employee_id: current_employee.id,
      team_id: @team.id,
      finished_at: nil
    )
  end

  def can_modify?
    return false if current_employee.nil?
    return false if @announcement.nil?

    is_the_author = (@announcement.employee_id == current_employee.id)
    return false unless is_the_author

    return true if @announcement.team_id.nil?

    Membership.exists?(
      employee_id: current_employee.id,
      team_id: @announcement.team_id,
      finished_at: nil
    )
  end

  private

  def current_employee
    return nil if @user.nil?

    @current_employee ||= Employee.find_by(user_id: @user.id)
  end
end
