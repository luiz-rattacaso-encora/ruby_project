class EmployeesController < ApplicationController
    def index
        @employees = Employee.all
    end

    def new
        @employee = Employee.new
    end

    def create
        @employee = Employee.new(employee_params)

        if @employee.save
            redirect_to "/employees"
        else
            render :new
        end
    end

    def show
        @employee = Employee.find(params[:id])
    end

    def edit
        @employee = Employee.find(params[:id])
    end

    def update
        @employee = Employee.find(params[:id])

        if @employee.update(employee_params)
            redirect_to "/employees/#{params[:id]}"
        else
            render :edit
        end
    end

    private
    def employee_params
        params.expect(employee: [ :first_name, :last_name, :role, :is_manager, :manager_id ])
    end
end
