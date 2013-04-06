class RegisterController < ApplicationController
  def index
    render :text => 'OK'
  end

  def create
    name = params['name'].downcase
    phone_number = params['phone_number']
    contact_name = params['contact_name'].downcase
    contact_phone_number = params['contact_phone_number']
    
    unless name.nil? or phone_number.nil? or contact_name.nil? or contact_phone_number.nil?
      system_number = get_twilio_system_number
      user = User.new(:name => name,
                       :phone_number => '+' + phone_number,
                       :contact_name => contact_name,
                       :contact_phone_number => '+' + contact_phone_number,
                       :system_number => system_number)
      user.save!
    end

    render :text => system_number
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
