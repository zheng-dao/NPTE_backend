class CreateUserAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :user_answers do |t|
      t.boolean :is_right
      t.text :description
      t.references :user
      t.references :question
      t.references :question_option

      t.timestamps
    end
  end
end
