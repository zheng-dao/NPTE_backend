class ApplicationMailer < ActionMailer::Base
  default from: ENV["FROM_EMAIL_NPTE"]
  layout 'mailer'
end
