class MembershipsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_member, only: [ :edit, :update, :show, :destroy ]

  def index
    @memberships = Membership.includes(:employee, :team).where(finished_at: nil)

    if params[:search_name].present?
      @memberships = @memberships.joins(:employee).merge(Employee.by_name(params[:search_name]))
    end

    respond_to do |format|
      format.html
      format.json { render json: @memberships, status: :ok }
    end
  end

  def new
    @membership = Membership.new
  end

  def create
    @membership = Membership.new(membership_params)

    respond_to do |format|
      if @membership.save
        format.html { redirect_to memberships_path, notice: "Membership was successfully created." }
        format.json { render json: @membership, status: :created, location: @membership }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @membership.update(membership_params)
        format.html { redirect_to employee_path(@membership.employee_id), notice: "Membership was successfully updated." }
        format.json { render json: @membership, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @membership.update_column(:finished_at, Time.current)
        format.html { redirect_to memberships_path, notice: "Membership was successfully finished." }
        format.json { head :no_content }
      else
        format.html { redirect_to memberships_path, alert: "Could not finish membership." }
        format.json { render json: { error: "Could not finish membership" }, status: :unprocessable_entity }
      end
    end
  end

  def show
    @membership = Membership.includes(:employee, :team).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @membership, status: :ok }
    end
  end

  private

  def membership_params
    params.expect(membership: [ :employee_id, :team_id ])
  end

  def set_member
    @membership = Membership.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to memberships_path, alert: "Membership not found." }
      format.json { render json: { error: "Membership not found" }, status: :not_found }
    end
  end
end
