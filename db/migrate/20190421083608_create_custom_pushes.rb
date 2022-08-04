class CreateCustomPushes < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_pushes do |t|
      t.text :push_text
      t.string :status

      t.timestamps
    end
  end
end
