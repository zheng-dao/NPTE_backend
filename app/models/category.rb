class Category < ApplicationRecord

  ############ Associations ##############

  has_many :questions


  ############ Validations ##############
  validates :name, presence: true

end
