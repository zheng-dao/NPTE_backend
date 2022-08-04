class QuestionOption < ApplicationRecord

  ############ Associations ##############

  # belongs_to :question, validate: true

  ############ Validations ##############
  validates :choice, presence: true


  def pretty_name
    choice if choice
  end

  rails_admin do
    object_label_method do
      :pretty_name
    end

    field :choice
  end

end
