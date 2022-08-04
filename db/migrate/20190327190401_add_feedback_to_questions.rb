class AddFeedbackToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :feedback, :text
  end
end
