class Api::V1::SessionsController < ApplicationController

  def new

  end

  def create
    @user = User.where(email: params[:email]).first
    if @user && @user.valid_password?(params[:password])
      @user.update_user_api_token(create_new=true)
      @user.reload
      @user.setup_devices(params[:PushToken]) if params[:PushToken].present?
      @user.user_image = @user.profile_image
      render json: @user, status: :created
    else
      render :json => {:error => "Email or password is not correct"}, :status => 404
    end
  end

  def destroy
    user = User.where(id: params[:id]).first
    if user
      user.update_user_api_token(create_new=false)
      user.reload
      render json: user.as_json, status: :created
    else
      render :json => {:error => "User not found"}, :status => 404
    end
  end


end