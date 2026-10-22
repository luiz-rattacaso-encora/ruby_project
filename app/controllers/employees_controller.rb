class EmployeesController < ApplicationController
    def index
        @employees = Employee.all
    end

    def new
        @employee = Employee.new
    end

    def create
        @employee = Employee.create(employee_params)
    end

    private
    def employee_params
        params.expect(employee: [ :first_name, :last_name, :role, :is_manager, :manager_id ])
    end
end
