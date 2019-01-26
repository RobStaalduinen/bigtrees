class ApplicationMailer < ActionMailer::Base
  default from: "no-replay@bigtrees.ca"
  layout 'mailer'
  
  if Rails.env.development?
    ActionMailer::Base.delivery_method = :letter_opener
  else  
    ActionMailer::Base.delivery_method = :sendmail
  end

	ActionMailer::Base.sendmail_settings = { :address => "smtp.gmail.com",
    :port => "587", :domain => "gmail.com", :user_name => "xxx@gmail.com", 
    :password => "yyy", :authentication => "plain", :enable_starttls_auto => true }
end
