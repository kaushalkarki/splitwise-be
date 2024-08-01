class UserMailer < ApplicationMailer
    default from: 'from@example.com'
  
    def welcome_email(user)
      @user = user
      mail(to: @user.email, subject: 'Welcome to My Awesome Site')
    end
  
    def notification_email(user)
      @user = user
      mail(to: @user.email, subject: 'You have a new notification')
    end
end
