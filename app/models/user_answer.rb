class UserAnswer < ApplicationRecord

  validates :user_id, :question_id, :question_option_id, presence: true

  scope :right, -> { where('is_right IS TRUE') }
  scope :wrong, -> { where('is_right IS FALSE') }
  scope :by_category, -> (cat_id) { where('category_id=?', cat_id) }
  scope :created_between, lambda {|start_date, end_date| where(:created_at => start_date..end_date )}

  def mark_question
    self.is_right = QuestionOption.find(self.question_option_id).is_correct
    self.save!
  end

end
