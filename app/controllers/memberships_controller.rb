class MembershipsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_member, only: [ :edit, :update, :show, :destroy ]

  def index
    @memberships = Membership.includes(:employee, :team).where(finished_at: nil)

    if params[:search_name].present?
      @memberships = @memberships.joins(:employee).merge(Employee.by_name(params[:search_name]))
    end
  end

  def new
    @membership = Membership.new
  end

  def create
    @membership = Membership.new(membership_params)

    if @membership.save
      redirect_to "/memberships"
    else
      render :new, alert: "Oops! something went wrong here"
    end
  end

  def update
    if @membership.update(membership_params)
        redirect_to "/employees/#{params[:employee_id]}"
    else
        render :edit
    end
  end

  def edit
  end

    def destroy
      if @membership.update_column(:finished_at, Time.current)
        redirect_to memberships_path, notice: "Membership was successfully finished."
      else
        redirect_to memberships_path, alert: "Could not finish membership."
      end
    end


  def show
    @membership = Membership.includes(:employee, :team).find(params[:id])
  end

  private
  def membership_params
    params.expect(membership: [ :employee_id, :team_id ])
  end

  def set_member
    @membership = Membership.find(params[:id])
  end
end
