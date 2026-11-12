class WeeklyUpdatesController < ApplicationController
  before_action :set_team, only: [ :index, :new, :create ]
  before_action :set_weekly_update, only: [ :show, :edit, :update, :destroy ]

  def index
    @weekly_updates = @team.weekly_updates.includes(:author)
    @weekly_updates = @weekly_updates.by_author_name(params[:author_name])
    @weekly_updates = @weekly_updates.by_status(params[:status])
  end

  def show
  end

  def new
    @weekly_update = @team.weekly_updates.new
  end

  def edit
    @team = @weekly_update.team
  end

  def create
    @weekly_update = @team.weekly_updates.new(weekly_update_params)
    @weekly_update.author = current_employee

    if @weekly_update.save
      redirect_to @weekly_update, notice: "Weekly update was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @team = @weekly_update.team
    @weekly_update.author = current_employee

    if @weekly_update.update(weekly_update_params)
      redirect_to @weekly_update, notice: "Weekly update was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    team = @weekly_update.team
    @weekly_update.destroy
    redirect_to team_weekly_updates_path(team), notice: "Weekly update was successfully destroyed."
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  def set_weekly_update
    @weekly_update = WeeklyUpdate.find(params[:id])
  end

  def current_employee
    Employee.find_by(user_id: Current.user.id)
  end

  def weekly_update_params
    params.require(:weekly_update).permit(:content, :status)
  end
end
