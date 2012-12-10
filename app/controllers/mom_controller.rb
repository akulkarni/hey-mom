class MomController < ApplicationController
  SON = '+19175731568'
  MOM = '+16617480240'

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
    unless params['CallSid'].nil?
      pc = PhoneCall.where('call_sid = ?', params['CallSid']).first
      unless pc.nil?
        pc.duration = params['CallDuration']
        pc.status = params['CallStatus']
      else
        pc = PhoneCall.new(:inbound => params['Direction'], :duration => params['CallDuration'], :call_sid => params['CallSid'], :status => params['CallStatus'])
      end

      # we don't always know if a call went to voicemail, so we assume short calls were missed
      if (params['AnsweredBy'] == 'machine') or (params['CallDuration'].to_i < 75)
        puts 'missed!'
        pc.missed_call = true
        if params['AnsweredBy'] == 'machine'
          # probably a better way to do this
          pc.duration = 0
        end
      end

      pc.save!
    end
    render :text => 'OK'
  end

  def asdf
    render :nothing => true
  end

  def create
    # Parameters: {"AccountSid"=>"AC2c0c745ec4d44b2e8c34ce702d81dadd", "ToZip"=>"", "FromState"=>"NY", "Called"=>"+19177192233", "FromCountry"=>"US", "CallerCountry"=>"US", "CalledZip"=>"", "Direction"=>"inbound", "FromCity"=>"NEW YORK", "CalledCountry"=>"US", "CallerState"=>"NY", "CallSid"=>"CA7287ed5793ee58458ea8ffb931e49224", "CalledState"=>"NY", "From"=>"+19175731568", "CallerZip"=>"10028", "FromZip"=>"10028", "CallStatus"=>"ringing", "ToCity"=>"", "ToState"=>"NY", "To"=>"+19177192233", "ToCountry"=>"US", "CallerCity"=>"NEW YORK", "ApiVersion"=>"2010-04-01", "Caller"=>"+19175731568", "CalledCity"=>""}
#    puts params

    unless params['AccountSid'].nil?

      if params['From'] == SON
        # son --> mom
        counterparty = MOM
        direction = 'outbound'
        name = 'Ajay'
      elsif params['From'] == MOM
        # mom --> son
        counterparty = SON
        direction = 'inbound'
        name = 'Mom'
      end

      pc = PhoneCall.new(:inbound => direction, :duration => 0, :call_sid => params['CallSid'])
      pc.save!

      # build up a response
      greeting = 'Hi %s, connecting you right now.' % name
      response = Twilio::TwiML::Response.new do |r|
        r.Say greeting, :voice => 'woman'
        r.Dial :callerId => '+19177192233' do |d|
          d.Number counterparty
        end
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
#                                    :application_sid => 'APdc87b7898e076eb779098b3293d0e60a',
                                    :url => 'http://callmom.herokuapp.com/mom',
                                  :status_callback => 'http://callmom.herokuapp.com/mom/call_ended',
                                    :if_machine => 'hangup'
                                  })

#    pc = PhoneCall.new(:direction => 'outbound', :duration => 0, :call_sid => @call.sid)
#    pc.save!

    render :text => 'OK'
  end

  def logs
    @phone_calls = PhoneCall.order(:created_at).reverse_order
#    @phone_calls = PhoneCall.all
  end

end
