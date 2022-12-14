# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @role = request.env['PATH_INFO'] == "/owner_sign_up" ? 1 : 0
    @user = User.new
  end

  # POST /resource
  def create
    role = @_params['role'].to_i
    user = User.create!(email: @_params['email'], password: @_params['password'], role: role)
    sign_in(user)
    # redirect_to user_session_path, data: { "turbo-method": :post, user: {email: @_params['email'], password: @_params['password'], remember_me: '1'} }
    if role == 0
      redirect_to root_path
    else
      redirect_to_after_sign_in_path
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    @_params = params.require(:user).permit(:email, :password, :role).to_hash
  end

  # If you have extra params to permit, append them to the sanitizer  .
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
