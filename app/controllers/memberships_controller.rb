class MembershipsController < ApplicationController
  before_action :set_member, only: [ :edit, :update ]
  def new
    @membership = Membership.new
  end

  def create
    @membership = Membership.new(membership_params)

    if @membership.save
      redirect_to "/teams"
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
  end

  def show
  end

  private
  def membership_params
    params.expect(membership: [ :employee_id, :team_id ])
  end

  def set_member
    @membership = Membership.find(params[:id])
  end
end
