class CreateJoinTableCustomPushesUsers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :custom_pushes, :users do |t|
      # t.index [:custom_push_id, :user_id]
      # t.index [:user_id, :custom_push_id]
    end
  end
end
