class TestController < ApplicationController
  # methods that make development easier

  def call
    # set up a client to talk to the Twilio REST API
    account_sid = 'AC2c0c745ec4d44b2e8c34ce702d81dadd'
    auth_token = '4c8d9d87c5e4b1f0634a6a27e9bc9300'
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
