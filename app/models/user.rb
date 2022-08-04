class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ############ Associations ##############
  has_one_attached :avatar
  has_many :user_answers, dependent: :destroy
  has_many :user_devices, dependent: :destroy
  has_many :push_logs, dependent: :destroy
  # has_and_belongs_to_many :custom_pushes

  attr_accessor :user_image

  ############ Validations ##############
  validates :email, :first_name, :last_name, presence: true
  validates :email, uniqueness:  true

  validates :avatar, content_type: {in: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif'], message: 'Please upload a valid image'}
  validates :avatar, size: { less_than: 2.megabytes , message: 'Image size should be less than 2 MB' }
  #

  def pretty_name
    first_name + " " + last_name if first_name && last_name
  end

  rails_admin do
    configure :set_password

    edit do
      exclude_fields :password, :password_confirmation
      include_fields :set_password
    end
    object_label_method do
      :pretty_name
    end

    field :first_name
    field :last_name
  end

  # Provided for Rails Admin to allow the password to be reset
  def set_password; nil; end

  def set_password=(value)
    return nil if value.blank?
    self.password = value
    self.password_confirmation = value
  end

  def admin
    self.role == "admin"
  end

  def gender_enum
    ['Male', 'Female']
  end

  def role_enum
    ['admin', 'appuser']
  end


  # Assign an API Token on create
  before_create do |user|
    user.api_token = User.generate_api_token
  end

  # Generate a unique API Token
  def self.generate_api_token
    loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless User.exists?(api_token: token)
    end
  end

  def update_user_api_token(create_new=false)
    self.api_token = create_new ? User.generate_api_token : nil
    self.save(:validate => false)
  end

  def has_answered(q)
    self.user_answers.where(question_id: q.id).first.present?
  end

  def profile_image
    # host = Rails.env == 'production' ? 'https://nptequiz.herokuapp.com' :'http://localhost:3000'
    if self.avatar.attached?
      path = Rails.application.routes.url_helpers.rails_blob_path(self.avatar, only_path: true)
    else
      path = "/images/user.png"
    end
    (ENV['MY_HOST'].to_s+path)
  end

  def setup_devices(token)
    self.de_active_devices
    device = self.user_devices.where(push_token: token).first_or_create
    device.set_active
  end

  def de_active_devices
    self.user_devices.update_all(is_active: false)
  end

  def send_push
    if self.user_devices.active.first.present?
      response = FcmPush.new.send_push_notification('','','')
      self.push_logs.new.save_log(response)
    end
  end

  def active_device
    self.user_devices.active.first
  end

  def attributes
    {id: self.id, email: self.email, first_name: self.first_name, last_name: self.last_name, created_at: self.created_at,
     updated_at: self.updated_at, phone: self.phone, gender: self.gender, address: self.address, api_token: self.api_token, user_image: self.profile_image}
  end


end
