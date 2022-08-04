class PushLog < ApplicationRecord

  store :body, coder: JSON

  def save_log(response)
    self.body = response
    self.success = eval(response[:body])[:success]
    self.save
  end
end
