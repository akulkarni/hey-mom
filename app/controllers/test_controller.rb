class TestController < ApplicationController
  # methods that make development easier

  def index
    render :text => 'OK'
  end

  def create_dummy_call
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new account_sid, auth_token
    
    @account = @client.account
    @call = @account.calls.create({:from => '+19177192233', :to => '+19175731568',
                                    :url => 'http://callmom.herokuapp.com/mom',
                                    :status_callback => 'http://callmom.herokuapp.com/mom/call_ended',
                                    :if_machine => 'hangup'
                                  })
    render :text => 'OK'
  end

  def create_dummy_log
    direction = 'outbound'
    duration = 5
    call_sid = 'TEST-%s' % rand()

    pc = PhoneCall.new(:direction => direction, :duration => duration, :call_sid => call_sid)
    pc.save!

    render :text => 'OK'
  end

end
