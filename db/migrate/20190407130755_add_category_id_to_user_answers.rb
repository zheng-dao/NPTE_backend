class AddCategoryIdToUserAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :user_answers, :category_id, :integer
  end
end
