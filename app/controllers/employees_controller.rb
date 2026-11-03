class EmployeesController < ApplicationController
    before_action :set_employee, only: [ :show, :edit, :update, :destroy ]
    before_action :employee_is_allowed_to_edit?, only: [ :edit, :update ]
    before_action :employee_is_allowed_to_create_and_destroy?, only: [ :new, :destroy ]
    before_action :select_manager, only: [ :new, :edit ]

    def index
        @employees = Employee.where(manager_id: Current.user.id)
    end

    def all
        @employees = Employee.all
    end

    def new
        @employee = Employee.new
        @employee.build_user
    end

    def create
        @employee = Employee.new(employee_params)

        if @employee.save
            redirect_to "/employees"
        else
            select_manager
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

    def employee_is_allowed_to_edit?
      policy = EmployeePolicy.new(Current.user, @employee)

        unless policy.can_update?
            redirect_to "/", alert: "You are not alloed to update"
        end
    end

    def employee_is_allowed_to_create_and_destroy?
        policy = EmployeePolicy.new(Current.user, @employee)

        unless policy.can_create_and_destroy?
            redirect_to "/", alert: "You are not alloed to create or delete an employee"
        end
    end

    def employee_params
        params.expect(employee: [ :first_name, :last_name, :role, :is_manager, :manager_id, :user_id, user_attributes: [ :email_address, :password, :password_confirmation ] ])
    end
end
