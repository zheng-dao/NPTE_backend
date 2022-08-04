class AddTodayQuestionToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :today_question, :boolean, default: false
  end
end
