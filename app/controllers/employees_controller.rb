class EmployeesController < ApplicationController
    before_action :set_employee, only: [ :show, :edit, :update, :destroy ]
    before_action :select_manager, only: [ :new, :edit ]

    def index
        @employees = Employee.where(manager_id: Current.user.id)
    end

    def all
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
    end

    def edit
    end

    def update
        if @employee.update(employee_params)
            redirect_to "/employees/#{params[:id]}"
        else
            render :edit
        end
    end

    def destroy
        @employee.destroy
        redirect_to "/employees"
    end

    private
    def set_employee
        @employee = Employee.find(params[:id])
    end

    def select_manager
        if @employee&.id
            @manager = Employee.where.not(id: @employee.id).where(is_manager: true)
        else
            @manager = Employee.where(is_manager: true)
        end
    end

    def employee_params
        params.expect(employee: [ :first_name, :last_name, :role, :is_manager, :manager_id, :user_id ])
    end
end
