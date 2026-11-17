# db/seeds.rb

puts "Cleaning database..."
Announcement.destroy_all
WeeklyUpdate.destroy_all
Membership.destroy_all
Team.destroy_all
Employee.update_all(manager_id: nil)
Employee.destroy_all
User.destroy_all

puts "Creating Teams..."
team_management = Team.create!(
  name: "Management",
  description: "Branch leadership and corporate liaisons.",
  technologies: [ "Whiteboard", "World's Best Boss Mug", "CRM" ]
)

team_sales = Team.create!(
  name: "Sales",
  description: "The primary revenue drivers for Dunder Mifflin Scranton.",
  technologies: [ "Phones", "Rolodex", "Paper Catalogs" ]
)

team_accounting = Team.create!(
  name: "Accounting",
  description: "Number crunchers ensuring the branch stays profitable.",
  technologies: [ "Excel", "Calculators", "Filing Cabinets" ]
)

team_ops = Team.create!(
  name: "Operations & Support",
  description: "Customer service, reception, supplier relations, and quality assurance.",
  technologies: [ "Switchboard", "Solitaire", "Vendor Databases" ]
)

team_hr = Team.create!(
  name: "Human Resources",
  description: "Corporate rule enforcers (mostly just Toby).",
  technologies: [ "HR Manuals", "Complaint Boxes" ]
)

team_warehouse = Team.create!(
  name: "Warehouse",
  description: "Blue-collar team handling physical paper inventory and shipping.",
  technologies: [ "Forklifts", "Balers", "Pallet Jacks" ]
)

puts "Creating Users and Employees..."

# Helper method to create a user and their employee record
def hire_employee(first_name, last_name, role, is_manager, manager_record = nil)
  email = "#{first_name.downcase}@#{first_name.downcase}.com"
  password = first_name.downcase

  user = User.create!(
    email_address: email,
    password: password,
    password_confirmation: password
  )

  # Assuming Employee belongs to User and optionally belongs to a manager (self-referential)
  Employee.create!(
    user: user,
    first_name: first_name,
    last_name: last_name,
    role: role,
    is_manager: is_manager,
    manager_id: manager_record&.id # Reference for self-join. Might be manager_id depending on your model setup.
  )
end

# 1. Management / Corporate
michael = hire_employee("Michael", "Scott", "Regional Manager", true)
toby    = hire_employee("Toby", "Flenderson", "HR Representative", true)
jim     = hire_employee("Jim", "Halpert", "Co-Manager", true, michael)
dwight  = hire_employee("Dwight", "Schrute", "Assistant to the Regional Manager", true, michael)

# 2. Sales
stanley = hire_employee("Stanley", "Hudson", "Sales Representative", false, michael)
phyllis = hire_employee("Phyllis", "Vance", "Sales Representative", false, michael)
andy    = hire_employee("Andy", "Bernard", "Sales Representative", false, michael)

# 3. Accounting
angela = hire_employee("Angela", "Martin", "Head of Accounting", true, michael)
kevin  = hire_employee("Kevin", "Malone", "Accountant", false, angela)
oscar  = hire_employee("Oscar", "Martinez", "Accountant", false, angela)

# 4. Support & Operations
pam      = hire_employee("Pam", "Beesly", "Receptionist", false, michael)
kelly    = hire_employee("Kelly", "Kapoor", "Customer Service Representative", false, michael)
creed    = hire_employee("Creed", "Bratton", "Quality Assurance Director", false, michael)
meredith = hire_employee("Meredith", "Palmer", "Supplier Relations", false, michael)

# 5. Warehouse
darryl = hire_employee("Darryl", "Philbin", "Warehouse Foreman", true, michael)
roy    = hire_employee("Roy", "Anderson", "Warehouse Worker", false, darryl)
nate   = hire_employee("Nate", "Nickerson", "Warehouse Worker", false, darryl)


puts "Assigning Team Memberships..."

# Helper method to add an employee to a team
def assign_to_team(employee, team)
  Membership.create!(employee: employee, team: team, finished_at: nil)
end

assign_to_team(michael, team_management)
assign_to_team(jim, team_management)
assign_to_team(dwight, team_management)

assign_to_team(jim, team_sales)
assign_to_team(dwight, team_sales)
assign_to_team(stanley, team_sales)
assign_to_team(phyllis, team_sales)
assign_to_team(andy, team_sales)

assign_to_team(angela, team_accounting)
assign_to_team(kevin, team_accounting)
assign_to_team(oscar, team_accounting)

assign_to_team(pam, team_ops)
assign_to_team(kelly, team_ops)
assign_to_team(creed, team_ops)
assign_to_team(meredith, team_ops)

assign_to_team(toby, team_hr)

assign_to_team(darryl, team_warehouse)
assign_to_team(roy, team_warehouse)
assign_to_team(nate, team_warehouse)


puts "Creating Announcements..."

Announcement.create!(
  author: michael,
  team: team_management,
  title: "Conference Room Meeting in 5 Minutes",
  content: "Everyone drop what you are doing and come to the conference room immediately. Mandatory attendance."
)

Announcement.create!(
  author: michael,
  title: "Today is Pretzel Day!",
  content: "Free pretzels are being served in the lobby. Do not cut in line."
)

Announcement.create!(
  author: michael,
  title: "Fire Safety Drill",
  content: "Please remain calm and follow Dwight's instructions during today's safety simulation."
)


puts "Creating Weekly Updates..."

WeeklyUpdate.create!(
  author: michael,
  team: team_sales,
  content: "Sales are up 5% this week! Great job everyone. Let's keep pushing paper.",
  published_date: Time.current,
  status: "published"
)

WeeklyUpdate.create!(
  author: angela,
  team: team_accounting,
  content: "Please submit all expense reports by Friday at 5 PM. Kevin, double-check your math before submitting.",
  published_date: Time.current - 1.week,
  status: "published"
)

puts "✅ Seed completed successfully! Welcome to Dunder Mifflin."
