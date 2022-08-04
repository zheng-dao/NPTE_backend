class FcmPush

  require 'fcm'

  def initialize
    @fcm = FCM.new("AIzaSyDK-692QLw3QPJp4wCn8OphI7cdvzJ3TVY")
  end

  def send_push_notification(title="NPTE", body="NPTE", reg_ids=[])
    options = {
        "notification": {
        "title": title,
        "body": body
        }
    }
    response = @fcm.send(reg_ids, options)
    PushLog.new.save_log(response)
  end

  def send_daily_push
    q= Question.question_of_day
    if q.present? && UserDevice.active.present?
      # UserDevice.active.each do |device|
      #   token = []
      #   token.push(device.push_token)
      #   send_push_notification('Question of the day', q.question_text, token)
      # end
      send_push_notification('Question of the day', q.question_text, UserDevice.active.pluck(:push_token))
    end
  end

end