class CreateQuestionOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :question_options do |t|
      t.text :choice
      t.boolean :is_correct, default: false
      t.references :question

      t.timestamps
    end
  end
end
