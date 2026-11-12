class WeeklyUpdatesController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_team, only: [ :index, :new, :create ]
  before_action :set_weekly_update, only: [ :show, :edit, :update, :destroy ]

  before_action :authorize_team_access!, only: [ :index, :new, :create ]
  before_action :authorize_weekly_update_view!, only: [ :show ]
  before_action :authorize_weekly_update_modification!, only: [ :edit, :update, :destroy ]

  def index
    @weekly_updates = @team.weekly_updates.includes(:author)
    @weekly_updates = @weekly_updates.by_author_name(params[:author_name])
    @weekly_updates = @weekly_updates.by_status(params[:status])

    respond_to do |format|
      format.html
      format.json { render json: @weekly_updates, status: :ok }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @weekly_update, status: :ok }
    end
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

    respond_to do |format|
      if @weekly_update.save
        format.html { redirect_to @weekly_update, notice: "Weekly update was successfully created." }
        format.json { render json: @weekly_update, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @weekly_update.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @team = @weekly_update.team
    @weekly_update.author = current_employee

    respond_to do |format|
      if @weekly_update.update(weekly_update_params)
        format.html { redirect_to @weekly_update, notice: "Weekly update was successfully updated." }
        format.json { render json: @weekly_update, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @weekly_update.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    team = @weekly_update.team
    @weekly_update.destroy

    respond_to do |format|
      format.html { redirect_to team_weekly_updates_path(team), notice: "Weekly update was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to teams_path, alert: "Team not found." }
      format.json { render json: { error: "Team not found" }, status: :not_found }
    end
  end

  def set_weekly_update
    @weekly_update = WeeklyUpdate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Weekly update not found." }
      format.json { render json: { error: "Weekly update not found" }, status: :not_found }
    end
  end

  def current_employee
    @current_employee ||= Employee.find_by(user_id: Current.user&.id)
  end

  def authorize_team_access!
    unless Current.user
      respond_to do |format|
        format.html { redirect_to new_session_path, alert: "You must log in first." }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
      return
    end

    policy = WeeklyUpdatePolicy.new(Current.user, @team)
    unless policy.can_view? || policy.can_create?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "You are not allowed to access this team." }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def authorize_weekly_update_view!
    unless Current.user
      respond_to do |format|
        format.html { redirect_to new_session_path, alert: "You must log in first." }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
      return
    end

    policy = WeeklyUpdatePolicy.new(Current.user, @weekly_update)
    unless policy.can_view?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "You are not allowed to view this update." }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def authorize_weekly_update_modification!
    unless Current.user
      respond_to do |format|
        format.html { redirect_to new_session_path, alert: "You must log in first." }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
      return
    end

    policy = WeeklyUpdatePolicy.new(Current.user, @weekly_update)
    unless policy.can_modify?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "You are not allowed to modify this update." }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def current_employee
    Employee.find_by(user_id: Current.user.id)
  end

  def weekly_update_params
    params.require(:weekly_update).permit(:content, :status)
  end
end
