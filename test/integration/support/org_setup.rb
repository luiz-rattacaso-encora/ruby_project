# Small, realistic org used by the endpoint tests. The default fixtures have
# employees without users and invalid weekly update statuses, so each test
# builds its own records instead.
#
#   boss (manager) ─┬─ worker   (member of :alpha)
#                   └─ lead (manager, member of :alpha)
#   outsider (no manager, no team)
module OrgSetup
  PASSWORD = "Secret123!".freeze

  def build_org
    @alpha = Team.create!(name: "Alpha #{SecureRandom.hex(3)}", description: "Alpha team", technologies: %w[Ruby Rails])
    @beta  = Team.create!(name: "Beta #{SecureRandom.hex(3)}",  description: "Beta team",  technologies: %w[React])

    @boss     = hire("Boss",     "Person", "Director",  manager: true)
    @lead     = hire("Lead",     "Person", "Team Lead", manager: true, reports_to: @boss)
    @worker   = hire("Worker",   "Person", "Developer", reports_to: @boss)
    @outsider = hire("Outsider", "Person", "Intern")

    Membership.create!(employee: @boss,   team: @beta)
    Membership.create!(employee: @lead,   team: @alpha)
    Membership.create!(employee: @worker, team: @alpha)

    @update = WeeklyUpdate.create!(team: @alpha, author: @worker, content: "Shipped login", status: "published")
    @announcement = Announcement.create!(author: @worker, team: @alpha, title: "Release", content: "v1 is out")
  end

  def hire(first, last, role, manager: false, reports_to: nil)
    user = User.create!(email_address: "#{first.downcase}-#{SecureRandom.hex(3)}@example.com",
                        password: PASSWORD, password_confirmation: PASSWORD)
    Employee.create!(user: user, first_name: first, last_name: last, role: role,
                     is_manager: manager, manager: reports_to)
  end

  def login(employee)
    sign_in_as(employee.user)
  end

  JSON_HEADERS = { "Accept" => "application/json" }.freeze

  def json
    JSON.parse(response.body)
  end
end
