class PasswordResetsController < ApplicationController
  before_action :user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_path
    elsif params[:password_reset][:email].empty?
      flash.now[:danger] = "Email address can't be empty"
      render 'new'
    elsif params[:password_reset][:email] !~ User::VALID_EMAIL_REGEX
      flash.now[:danger] = 'Email address incorrectly formatted'
      render 'new'
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      @user.update_columns(reset_digest: nil, reset_sent_at: nil)
      flash[:success] = 'Password has been reset'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user
  def valid_user
    return redirect_to root_path unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
  end

  # Checks expiration of reset token
  def check_expiration
    return false unless @user.password_reset_expired?
    flash[:danger] = 'Password reset has expired'
    redirect_to new_password_reset_path
  end
end
