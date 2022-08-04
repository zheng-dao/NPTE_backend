class UserDevice < ApplicationRecord

  ############ Associations ##############

  belongs_to :user
  has_many :push_logs, dependent: :destroy

  ############ Validations ##############
  validates :push_token, :user_id, presence: true

  scope :active, -> { where('is_active IS TRUE') }

  def set_active
    self.is_active = true
    self.save!
  end

end
