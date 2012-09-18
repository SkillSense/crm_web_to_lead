class AppCallback < FatFreeCRM::Callback::Base


  # Implements application's before_filter hook.
  #----------------------------------------------------------------------------
  def app_before_filter(controller, context = {})
  
    # Only trap leads/create.
    return unless controller.controller_name == "leads" && controller.action_name == "create"
  
    # Remote form should POST two hidden fields to identify the user who'll own the lead:
    # 
    # <input type="hidden" name="authorization" value="-- users.password_hash here --">
    # <input type="hidden" name="token"         value="-- users.password_salt here --">

    params = controller.params
    if controller.request.post? && !params[:authorization].blank? && !params[:token].blank?
      user = User.find_by_password_hash_and_password_salt(params[:authorization], params[:token])

      # Implant @current_user so that :require_user filter becomes a noop.
      params[:lead][:user_id] ||= user.id.to_s
      controller.instance_variable_set("@current_user", user)
      controller.logger.info(">>> web-to-lead: creating lead for user " + user.inspect) if controller.logger
    end
  end

end
