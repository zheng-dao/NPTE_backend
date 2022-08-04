class Question < ApplicationRecord

  ############ Associations ##############

  belongs_to :category
  has_many    :question_options
  has_one_attached :avatar
  has_many :today_question_logs

  ############ Validations ##############
  validates :question_text, :feedback, presence: true
  default_scope { order("created_at ASC") }
  attr_accessor :is_answered
  attr_accessor :question_image
  validates_length_of :question_options, maximum: 4

  validates :avatar, content_type: {in: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif'], message: 'Please upload a valid image'}
  validates :avatar, size: { less_than: 2.megabytes , message: 'Image size should be less than 2 MB' }

  def self.update_question_of_day
    question = Question.where("today_question IS TRUE").first || Question.first
    question.create_log
    question2 = question.next_question
    question2.set_as_today
    question.remove_from_today
  end

  def next_question
    self.class.where("id > ?", id).first || Question.first
  end

  def set_as_today
    self.update_column('today_question', true)
  end

  def remove_from_today
    self.update_column('today_question', false)
  end

  def create_log
    self.today_question_logs.create!
  end

  def triggered_date
    self.today_question_logs.last.try(:created_at)
  end

  def attributes
    {:id=>self.id, question_text: self.question_text, created_at: self.created_at,
    updated_at: self.updated_at, feedback: self.feedback, today_question: self.today_question, :is_answered=>nil, question_image: self.profile_image}
  end

  def profile_image
    # host = Rails.env == 'production' ? 'https://nptequiz.herokuapp.com' :'http://localhost:3000'
    if self.avatar.attached?
      if Rails.env=='production'
        path = self.avatar.variant(resize: "200x200").processed.service_url
      else
        path = ENV['MY_HOST'].to_s + Rails.application.routes.url_helpers.rails_blob_path(self.avatar, only_path: true)
      end
    else
      path = nil
    end
    path
  end


  class << self

    def question_of_day
      Question.where("today_question IS TRUE").first
    end

  end

end
