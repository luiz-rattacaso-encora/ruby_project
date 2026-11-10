class WeeklyUpdatesController < ApplicationController
  before_action :set_team, only: [ :index, :new, :create ]
  before_action :set_weekly_update, only: [ :show, :edit, :update, :destroy ]

  # GET /teams/:team_id/weekly_updates
  def index
    @weekly_updates = @team.weekly_updates
  end

  # GET /weekly_updates/:id
  def show
  end

  # GET /teams/:team_id/weekly_updates/new
  def new
    @weekly_update = @team.weekly_updates.new
  end

  # GET /weekly_updates/:id/edit
  def edit
  end

  # POST /teams/:team_id/weekly_updates
  def create
    @weekly_update = @team.weekly_updates.new(weekly_update_params)

    if @weekly_update.save
      redirect_to @weekly_update, notice: "Weekly update was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /weekly_updates/:id
  def update
    if @weekly_update.update(weekly_update_params)
      redirect_to @weekly_update, notice: "Weekly update was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /weekly_updates/:id
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

  def weekly_update_params
    params.require(:weekly_update).permit(:content, :status)
  end
end
