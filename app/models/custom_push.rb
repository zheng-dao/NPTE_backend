class CustomPush < ApplicationRecord

  after_create_commit :send_push_to_users

  has_and_belongs_to_many :users

  validates :push_text, presence: true

  private

  def send_push_to_users
    # push =CustomPush.last
    self.reload
    users= self.users.joins(:user_devices).uniq
    devices = []
    users.each do |u|
      devices.push(u.active_device.push_token) if u.active_device.present?
    end
    text = self.push_text
    if devices.present?
      p devices
      FcmPush.new.send_push_notification('NPTE',text, devices)
    end
  end

end
