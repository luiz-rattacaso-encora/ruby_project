# Internal Team Management System

## Project Objective
The main goal of this project is to provide a centralized internal platform to manage employees, organize teams, and improve corporate communication. The application allows users to securely log in, assigns employees to specific teams, and provides tools for sharing global announcements and submitting weekly progress updates.

## Prerequisites
Before you begin, ensure you have the following installed on your local machine:
* **Ruby** (v3.0.0 or higher recommended)
* **Ruby on Rails** (v7.0 or higher)
* **SQLite3** or **PostgreSQL** (depending on your database configuration)
* **Git**

## Initial Setup

Follow the steps below to configure and run the application in your local development environment:

### 1. Clone the repository
First, download the project files to your computer.
```bash
git clone https://github.com/luiz-rattacaso-encora/ruby_project.git
cd ruby_project
```

### 2. Install dependencies

Run Bundler to install all the required Ruby gems listed in the Gemfile.

```bash
bundle install
```

### 3. Database Configuration

Create the database, run the migrations to build the tables (Users, Employees, Teams, etc.), and populate it with initial data if available.

```bash
rails db:create
rails db:migrate
rails db:seed
```

### Create the First Admin User

This application uses Rails' built-in authentication system. Since there is no public sign-up page, you must create the initial user manually through the Rails console.

Open the console:

### 4. Start the application

Launch the local Rails web server.

```bash
rails server
```

### 5. Access the system

Open your web browser and navigate to: [http://localhost:3000](http://localhost:3000)

Note on Login: Since the database was populated using the seed file, you can log in using the sample credentials. For example, use the Regional Manager account:

    Email: michael@michael.com

    Password: michael