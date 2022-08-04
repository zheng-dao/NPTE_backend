class Api::V1::QuestionsController < ApplicationController
  before_action :verify_api_token
  before_action :set_question, only: [:show, :update, :destroy]
  # GET /questions
  def index
    @questions = Question.all
    render json: @questions, :include => [:category, :question_options ]
  end
  # GET /questions/1
  def show
    @question.question_image = @question.profile_image
    render :json => @question, :include => [:category, :question_options ]
    # render json: @question
  end
  # POST /questions
  def create
    @question = Question.new(question_params)
    if @question.save
      @question.question_image = @question.profile_image
      render json: @question, status: :created, location:        api_v1_question_url(@question)
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end
  # PATCH/PUT /questions/1
  def update
    if @question.update(question_params)
      render json: @question
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end
  # DELETE /questions/1
  def destroy
    @question.destroy
  end

  def today_question
    question = Question.where("today_question IS TRUE").first
    if question
      question.question_image = question.profile_image
      question.is_answered = @user.has_answered(question)
      render :json=> question, :include => [:category, :question_options]
    else
      render :json => {:error => "Record not found"}, :status => 404
    end
  end

  def previous_questions
    begin
      start_date = params[:start_date].present? ? DateTime.parse(params[:start_date]).beginning_of_day : (DateTime.now - 1.day).beginning_of_day
      end_date =   params[:end_date].present? ? DateTime.parse(params[:end_date]).end_of_day : (DateTime.now).end_of_day

      # questions = TodayQuestionLog.created_between(start_date, end_date).uniq
      questions = Question.joins(:today_question_logs).where('today_question_logs.created_at > ? AND today_question_logs.created_at < ?', start_date, end_date).uniq
      questions.map { |question| question.is_answered = @user.has_answered(question) }
      # questions = Question.joins(:today_question_logs).where('today_question_logs.created_at BETWEEN ? AND ?', start_date, end_date).uniq
      render json: questions, include: [:question_options], methods: [:triggered_date], :status => :ok
    rescue
      render :json => {:error => "Something went wrong!"}, :status => :unprocessable_entity
    end
  end

  def random_questions
    begin
      category_id = params[:category_id]
      questions = Question.limit(5).where('category_id = ?', category_id).uniq
      questions.map { |question| question.is_answered = @user.has_answered(question) }
      render json: questions, include: [:question_options], methods: [:triggered_date], :status => :ok
    rescue
      render :json => {:error => "Something went wrong!"}, :status => :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_question
    begin
      @question = Question.find(params[:id])
    rescue
      render :json => {:error => "Record not found"}, :status => 404
    end

  end
  # Only allow a trusted parameter “white list” through.
  def user_params
    params.require(:question).permit(:title, :content, :slug)
  end

  def verify_api_token
    return true if authenticate_token
    render json: { errors: "Access denied" }, status: 401
  end

  def authenticate_token
    return false if params[:api_token].blank?
    @user = User.find_by(api_token: params[:api_token])
    @user
  end


end