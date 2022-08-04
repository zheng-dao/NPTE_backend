class TodayQuestionLog < ApplicationRecord

  belongs_to :question

  scope :created_between, lambda {|start_date, end_date| where(:created_at => start_date..end_date )}
end
