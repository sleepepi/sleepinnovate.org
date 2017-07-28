# frozen_string_literal: true

# Allows admins to edit user accounts.
class Admin::UsersController < Admin::AdminController
  before_action :find_user_or_redirect, only: [:unrevoke, :show, :edit, :update, :destroy]

  # GET /admin/users
  def index
    @users = User.current.page(params[:page]).per(40)
  end

  # # GET /admin/users/1
  # def show
  # end

  # # GET /admin/users/1/edit
  # def edit
  # end

  # PATCH /users/1
  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User was successfully updated."
    else
      render :edit
    end
  end

  # # POST /admin/users/1/unrevoke
  def unrevoke
    @user.unrevoke_consent!
    redirect_to admin_user_path(@user)
  end

  # DELETE /admin/users/1
  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User was successfully deleted."
  end

  protected

  def find_user_or_redirect
    @user = User.current.find_by(id: params[:id])
    empty_response_or_root_path(users_path) unless @user
  end

  def user_params
    params.require(:user).permit(
      :full_name, :email
    )
  end
end
