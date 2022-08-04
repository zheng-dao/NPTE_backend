class Api::V1::UsersController < ApplicationController

  # skip_before_action :verify_authenticity_token

  before_action :verify_api_token, except: [:create, :forgot_password]
  before_action :set_user, only: [:show, :update, :destroy, :update_password, :user_report]
  # GET /users
  def index
    @users = User.all
    render json: @users
  end
  # GET /users/1
  def show
    @user.user_image = @user.profile_image
    render json: @user  end
  # POST /users
  def create
    pass = params[:user][:password]
    @user = User.new(user_params)
    # debugger
    @user.password=@user.password_confirmation=pass

    if @user.save
      if params[:image].present?
        process_user_image(@user, params[:image])
      end
      @user.user_image = @user.profile_image
      @user.setup_devices(params[:PushToken]) if params[:PushToken].present?
      render json: @user, status: :created
    else
      render :json => {:error => "Unable to create user at this time."}, :status => :unprocessable_entity
    end
  end
  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      if params[:image].present?
        process_user_image(@user, params[:image])
      end
      @user.user_image = @user.profile_image
      render json: @user
    else
      render :json => {:error => "Record not found"}, :status => :unprocessable_entity
    end
  end
  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def update_password
    if @user.update(user_params)
      @user.user_image = @user.profile_image
      render json: @user
    else
      render :json => {:error => "Record not found"}, :status => :unprocessable_entity
    end
  end

  def forgot_password
    @user = User.find_by_email(params[:email])
    if @user.present?
      @user.send_reset_password_instructions
      render :json => {:success => "Please check your email for password reset instructions"}, :status => :created
    else
      render :json => {:error => "Email not found"}, :status => :unprocessable_entity
    end
  end

  def user_report
    begin
      start_date = params[:start_date].present? ? DateTime.parse(params[:start_date]).beginning_of_day : @user.created_at
      end_date =   params[:end_date].present? ? DateTime.parse(params[:end_date]).end_of_day : DateTime.now
      answers = @user.user_answers.created_between(start_date, end_date)
      report = Hash.new
      if params[:by_category].present? && params[:by_category] == 'true'
        report = search_by_category answers
      elsif params[:by_month].present? && params[:by_month] == 'true'
        report = search_by_month answers
      else
        report = {:total=>answers.count, :right=> answers.right.count, :wrong=> answers.wrong.count }
      end
      render :json => {:report=>report}, :status => :ok
    rescue
      render :json => {:error => "Something went wrong!"}, :status => :unprocessable_entity
    end

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    begin
      @user = User.find(params[:id])
    rescue
      render :json => {:error => "User not found with provided id"}, :status => 404
    end
  end

  def search_by_category(answers)
    report = Hash.new
    Category.all.each do |category|
      report[category.name] = {:total=> answers.by_category(category.id).count, :right=> answers.right.by_category(category.id).count, :wrong=> answers.wrong.by_category(category.id).count }
    end
    report

  end

  def search_by_month(answers)
    start_month = DateTime.now.beginning_of_year.beginning_of_month
    report = Hash.new
    Date::MONTHNAMES.each do |month_name|
      if month_name.present?
        report[month_name] = {:total=> answers.created_between(start_month.beginning_of_month, start_month.end_of_month).count, :right=> answers.right.created_between(start_month.beginning_of_month, start_month.end_of_month).count, :wrong=> answers.wrong.created_between(start_month.beginning_of_month, start_month.end_of_month).count }
        start_month = start_month.next_month
      end
    end
    report
  end
  # Only allow a trusted parameter “white list” through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :phone, :gender, :address)
  end

  def verify_api_token
    return true if authenticate_token
    render json: { errors: "Access denied" }, status: 401
  end

  def authenticate_token
    return false if params[:api_token].blank?
    User.find_by(api_token: params[:api_token])
  end

  def process_user_image(user, img)
    if user.present? and img.present?
      # image decoding
      blob = Base64.decode64((img.split(',').length > 1 ? img.split(',')[1] : img))
      image = MiniMagick::Image.read(blob)
      image.write Rails.root.to_s+"/tmp/avatar.jpg"
      user.avatar.attach(io: File.open(Rails.root.to_s+"/tmp/avatar.jpg"), filename: 'avatar.jpg')
    end
  end

end