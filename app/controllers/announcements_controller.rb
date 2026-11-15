class AnnouncementsController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  before_action :set_current_employee
  before_action :set_announcement, only: [ :show, :edit, :update, :destroy ]
  before_action :set_team_for_creation, only: [ :create ]
  before_action :set_active_teams, only: [ :index, :new, :edit, :create, :update ]

  before_action :authorize_new_form!, only: [ :new ]
  before_action :authorize_announcement_creation!, only: [ :create ]
  before_action :authorize_announcement_view!, only: [ :show ]
  before_action :authorize_announcement_modification!, only: [ :edit, :update, :destroy ]

  def index
    @announcements = Announcement.includes(:author, :team).by_team(params[:team_id]).by_author_name(params[:author_name]).order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @announcements, status: :ok }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @announcement, status: :ok }
    end
  end

  def new
    @announcement = Announcement.new
  end

  def edit
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.author = current_employee

    respond_to do |format|
      if @announcement.save
        format.html { redirect_to announcements_path, notice: "Announcement was successfully created." }
        format.json { render json: @announcement, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @announcement.update(announcement_params)
        format.html { redirect_to @announcement, notice: "Announcement was successfully updated." }
        format.json { render json: @announcement, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to announcements_path, notice: "Announcement was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def current_employee
    @current_employee ||= Employee.find_by(user_id: Current.user&.id)
  end

  def set_current_employee
    unless current_employee
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Employee profile not found." }
        format.json { render json: { error: "Employee not found" }, status: :unauthorized }
      end
    end
  end

  def set_active_teams
    @teams = current_employee.active_teams.order(:name)
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to announcements_path, alert: "Announcement not found." }
      format.json { render json: { error: "Announcement not found" }, status: :not_found }
    end
  end

  def set_team_for_creation
    team_id = announcement_params[:team_id]
    @team = Team.find_by(id: team_id) if team_id.present?
  end

  def authorize_new_form!
    policy = AnnouncementPolicy.new(Current.user)
    unless policy.can_access_new_form?
      respond_to do |format|
        format.html { redirect_to announcements_path, alert: "You need an active team membership to create announcements." }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def authorize_announcement_creation!
    policy = AnnouncementPolicy.new(Current.user, team: @team)
    unless policy.can_create_for_team?
      respond_to do |format|
        format.html { redirect_to announcements_path, alert: "You are not allowed to post announcements for this team." }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def authorize_announcement_view!
    policy = AnnouncementPolicy.new(Current.user, announcement: @announcement)
    unless policy.can_view?
      respond_to do |format|
        format.html { redirect_to announcements_path, alert: "You are not allowed to view this announcement." }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def authorize_announcement_modification!
    policy = AnnouncementPolicy.new(Current.user, announcement: @announcement)
    unless policy.can_modify?
      respond_to do |format|
        format.html { redirect_to announcements_path, alert: "You are not allowed to modify this announcement." }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def announcement_params
    params.expect(announcement: [ :title, :content, :team_id ])
  end
end
