class RegisterController < ApplicationController
  def index
    render :text => get_twilio_system_number
  end

  def create
    render :text => 'OK'
  end

  def get_twilio_system_number
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    @numbers = @client.account.available_phone_numbers.get('US').local.list(:contains => 'MOM')
    @number = @numbers[0].phone_number
    @client.account.incoming_phone_numbers.create(:phone_number => @number)

    @client.account.incoming_phone_numbers.list({:phone_number => @number}).each do |registered_number|
      registered_number.update.update(:voice_url => ENV['HEYMOM_HOST'] + "/call",
                                      :status_callback => ENV['HEYMOM_HOST'] + "/call/call_ended")
    end

    return @number
  end

end
