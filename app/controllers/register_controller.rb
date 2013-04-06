class RegisterController < ApplicationController
  def index
    
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    @client.account.sms.messages.create(
                                        :from => '+19177192233',
                                        :to => '+19175731568',
                                        :body => 'Heyo!'
                                        )

    render :text => 'OK'
  end

  def create
    render :text => 'OK'
  end

  def get_twilio_system_number
    render :text => 'OK'    
  end

end
