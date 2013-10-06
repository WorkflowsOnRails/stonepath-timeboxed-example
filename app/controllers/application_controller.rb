class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  # TODO: Start using Cancan instead.
  def require_role(role_name)
    unless current_user.role.name == role_name
      flash[:error] = 'Access denied'
      redirect_to '/'
      return false
    end
    true
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :role_id
  end
end
