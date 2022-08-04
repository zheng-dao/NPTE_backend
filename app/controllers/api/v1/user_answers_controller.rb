class Api::V1::UserAnswersController < ApplicationController
  before_action :verify_api_token
  # before_action :set_question, only: [:show, :update, :destroy]
  # GET /questions
  def index
    @questions = Question.all
    render json: @questions, :include => [:category, :question_options ]
  end
  # GET /questions/1
  def show
    render :json => @question, :include => [:category, :question_options ]
    # render json: @question
  end
  # POST /questions
  def create
    @answer = UserAnswer.new(question_params)
    if @answer.save
      @answer.mark_question
      render json: @answer, status: :created, location: api_v1_question_url(@answer)
    else
      render :json => {:error => "Unable to create record at this time."}, status: :unprocessable_entity
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
  def question_params
    params.require(:answer).permit(:is_right, :description, :user_id, :question_id, :question_option_id, :category_id)
  end

  def verify_api_token
    return true if authenticate_token
    render json: { errors: "Access denied" }, status: 401
  end

  def authenticate_token
    return false if params[:api_token].blank?
    User.find_by(api_token: params[:api_token])
  end

end