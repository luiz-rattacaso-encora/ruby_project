class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
  def require_manager!
    return if Employee.exists?(user_id: Current.user&.id, is_manager: true)
    respond_to do |format|
    format.html { redirect_to root_path, alert: "Only managers can do this." }
    format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end
end
