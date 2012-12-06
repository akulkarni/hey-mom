class MomController < ApplicationController
  def index
    # render :text => 'it\'s cool'

    # set up a client to talk to the Twilio REST API
    account_sid = 'AC2c0c745ec4d44b2e8c34ce702d81dadd'
    auth_token = '4c8d9d87c5e4b1f0634a6a27e9bc9300'
    @client = Twilio::REST::Client.new account_sid, auth_token

    # send an sms
    # @client.account.sms.messages.create(
    #                              :from => '+19177192233',
    #                              :to => '+19175731568',
    #                              :body => 'HOOAH'
    #                             )

    # build up a response
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'hey buddy', :voice => 'woman'
    end

    render :xml => response.text
  end

  def call_ended
    puts params
    unless params['CallSid'].nil?
      phone_call = PhoneCall.where('call_sid = ?', params['CallSid'])
      puts phone_call
      unless phone_call.empty?
        phone_call.duration = params['CallDuration']
        phone_call.save!
      end
    end

    render :text => 'OK'
  end

  def create
    # Parameters: {"AccountSid"=>"AC2c0c745ec4d44b2e8c34ce702d81dadd", "ToZip"=>"", "FromState"=>"NY", "Called"=>"+19177192233", "FromCountry"=>"US", "CallerCountry"=>"US", "CalledZip"=>"", "Direction"=>"inbound", "FromCity"=>"NEW YORK", "CalledCountry"=>"US", "CallerState"=>"NY", "CallSid"=>"CA7287ed5793ee58458ea8ffb931e49224", "CalledState"=>"NY", "From"=>"+19175731568", "CallerZip"=>"10028", "FromZip"=>"10028", "CallStatus"=>"ringing", "ToCity"=>"", "ToState"=>"NY", "To"=>"+19177192233", "ToCountry"=>"US", "CallerCity"=>"NEW YORK", "ApiVersion"=>"2010-04-01", "Caller"=>"+19175731568", "CalledCity"=>""}

    unless params['AccountSid'].nil?
      pc = PhoneCall.new(:direction => 0, :duration => 0)
      pc.call_sid = params['CallSid']

      direction = -1
      case params['Direction']
      when 'outbound'
        direction = 0
      when 'inbound'
        direction = 1
      end

      pc.direction = direction

      pc.save!
      puts params

      # build up a response
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Got ya buddy', :voice => 'woman'
      end

      render :xml => response.text
    else
      render :text => params
    end

  end

  def call
    # set up a client to talk to the Twilio REST API
    account_sid = 'AC2c0c745ec4d44b2e8c34ce702d81dadd'
    auth_token = '4c8d9d87c5e4b1f0634a6a27e9bc9300'
    @client = Twilio::REST::Client.new account_sid, auth_token

    @account = @client.account
    @call = @account.calls.create({:from => '+19177192233', :to => '+19175731568',
                                    :application_sid => 'APdc87b7898e076eb779098b3293d0e60a'})
    render :text => 'OK'
  end
end
