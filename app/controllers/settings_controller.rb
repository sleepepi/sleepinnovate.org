# frozen_string_literal: true

# Displays settings pages.
class SettingsController < ApplicationController
  before_action :authenticate_user!

  layout "full_page"

  # # GET /settings
  # def settings
  # end

  # # GET /settings/password
  # def password
  # end

  # PATCH /settings/password
  def change_password
    if current_user.valid_password?(params[:user][:current_password])
      if current_user.reset_password(params[:user][:password], params[:user][:password_confirmation])
        bypass_sign_in current_user
        flash[:notice] = "Your password has been changed."
        redirect_to settings_path, notice: "Your password has been changed."
      else
        render :password
      end
    else
      current_user.errors.add(:current_password, "is invalid")
      render :password
    end
  end

  # # GET /settings/email
  # def email
  # end

  # PATCH /settings/email
  def change_email
    if current_user.valid_password?(params[:user][:current_password])
      if params[:user][:email].blank?
        current_user.errors.add(:email, "can't be blank")
        render :email
      elsif params[:user][:email] != params[:user][:email_confirmation]
        current_user.errors.add(:email_confirmation, "doesn't match Email")
        render :email
      elsif current_user.update(email: params[:user][:email])
        bypass_sign_in current_user
        flash[:notice] = "Your email has been changed."
        redirect_to settings_path, notice: "Your email has been changed."
      else
        render :email
      end
    else
      current_user.errors.add(:current_password, "is invalid")
      render :email
    end
  end
end
