class EmployeesController < ApplicationController
    skip_before_action :verify_authenticity_token

    before_action :set_employee, only: [ :show, :edit, :update, :destroy, :hierarchy ]
    before_action :employee_is_allowed_to_edit?, only: [ :edit, :update ]
    before_action :employee_is_allowed_to_create_and_destroy?, only: [ :new, :create, :destroy ]
    before_action :select_manager, only: [ :new, :edit ]

    def index
        @employee = Employee.find_by(user_id: Current.user.id)

        respond_to do |format|
            if @employee
                format.json { render json: @employee, status: :ok }
            else
                format.json { render json: { error: "Employee not found" }, status: :not_found }
            end
        end
    end

    def all
        @employees = Employee.all
        @employees = @employees.by_name(params[:search_name]) if params[:search_name].present?

        respond_to do |format|
            format.html # Renderiza app/views/employees/all.html.erb
            format.json { render json: @employees, status: :ok }
        end
    end

    def new
        @employee = Employee.new
        @employee.build_user
    end

    def create
        @employee = Employee.new(employee_params)

        respond_to do |format|
            if @employee.save
                format.json { render json: @employee, status: :created }
                format.html { redirect_to "/employees" }
            else
            select_manager
                format.json { render json: @employee.errors, status: :unprocessable_entity }
                format.html { render :new, status: :unprocessable_entity }
            end
        end
    end

    def show
    end

    def hierarchy
    end

    def edit
    end

    def update
        respond_to do |format|
            if @employee.update(employee_params)
                format.json { render json: @employee, status: :ok }
                format.html { redirect_to "/employees/#{params[:id]}" }
            else
                select_manager
                format.json { render json: @employee.errors, status: :unprocessable_entity }
                format.html { render :edit, status: :unprocessable_entity }
            end
        end
    end

    def destroy
        @employee.destroy
        respond_to do |format|
          format.json { head :no_content } # não existe mais nenhum dado dele para devolver no JSON. O comando head :no_content envia uma resposta vazia apenas com o status 204 No Content
          format.html { redirect_to "/employees" }
        end
    end

    private
    def set_employee
        @employee = Employee.find(params[:id])
    end

    def select_manager
        current_user = Current.user.id
        @manager = Employee.where.not(user_id: current_user).where(is_manager: true)
    end

    def employee_is_allowed_to_edit?
        policy = EmployeePolicy.new(Current.user, @employee)
        deny_access("You are not allowed to update") unless policy.can_update?
    end

    def employee_is_allowed_to_create_and_destroy?
        policy = EmployeePolicy.new(Current.user, @employee)
        deny_access("You are not allowed to create or delete an employee") unless policy.can_create_and_destroy?
    end

    def deny_access(message)
        respond_to do |format|
        format.json { render json: { error: message }, status: :forbidden }
        format.html { redirect_to root_path, alert: message }
        end
    end

    def employee_params
        params.expect(employee: [ :first_name, :last_name, :role, :is_manager, :manager_id, :user_id, user_attributes: [ :email_address, :password, :password_confirmation ] ])
    end
end
