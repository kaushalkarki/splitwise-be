class UserMailer < ApplicationMailer
    default from: 'from@example.com'
  
    def welcome_email(email)
      mail(to: email, subject: 'Splits Invitation')
    end
  
    def notification_email(user)
      @user = user
      mail(to: @user.email, subject: 'You have a new notification')
    end
end
