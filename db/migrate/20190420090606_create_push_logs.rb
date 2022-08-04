class CreatePushLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :push_logs do |t|
      t.text :body
      t.boolean :success, default: false
      t.integer :user_id
      t.integer :user_device_id

      t.timestamps
    end
  end
end
