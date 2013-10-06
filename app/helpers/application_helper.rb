module ApplicationHelper
  def nav_class_for_controller(*controller)
    is_active = controller.include?(params[:controller])
    is_active ? "active" : ""
  end

  def current_user_in_role(role_name)\
    return false if current_user.nil?
    current_user.role.name == role_name.to_s
  end
end
