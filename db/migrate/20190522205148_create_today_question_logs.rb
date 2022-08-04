class CreateTodayQuestionLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :today_question_logs do |t|
      t.integer :question_id

      t.timestamps
    end
  end
end
