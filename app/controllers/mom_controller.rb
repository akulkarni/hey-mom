class MomController < ApplicationController
  SON = '+19175731568'
  MOM = '+19739794384'

  def ok
    render :text => 'OK'
  end

  def index
    return ok
  end

  def call_ended
    unless params['CallSid'].nil?
      pc = PhoneCall.where('call_sid = ?', params['CallSid']).first
      unless pc.nil?
        pc.duration = params['CallDuration']
        pc.status = params['CallStatus']
      else
        puts 'creating new call'
        pc = PhoneCall.new(:inbound => get_inbound(params['Caller']), :duration => params['CallDuration'], :call_sid => params['CallSid'], :status => params['CallStatus'])
      end

      # we don't always know if a call went to voicemail, so we assume short calls were missed
      if (params['AnsweredBy'] == 'machine') or
          ((params['CallDuration'].to_i > 10) and (params['CallDuration'].to_i < 65))
        pc.missed_call = true
        if params['AnsweredBy'] == 'machine'
          # probably a better way to do this
          puts 'machine!'
          pc.duration = 0
        end
      end

      pc.save!

      # record response time from the previous call in the other direction
      pc_prev = PhoneCall.where(:inbound => !pc.inbound).last!
      unless pc_prev.nil?
        pc_prev.response_time = (pc.created_at - pc_prev.created_at).to_i
        pc_prev.save!
      end

    end
    render :text => 'OK'
  end

  def get_inbound(caller_number)
    caller_number == AJAY ? (return false) : (return true)
  end

  def grade
    @total_outbound = score_total_outbound_calls
    @total_seconds = score_total_seconds
    @average_response_time = score_average_response_time

    # to be a good son,
    #   call at least 3x a week
    #   speak for at least 60 minutes a week
    #   respond no later than a day after you miss a call
    @score = @total_outbound/3.to_f + @total_seconds/3600.to_f + 86400/@average_response_time.to_f

    case @score
      when 0...2
        @grade = 'F'
        @mom_picture = 'mom-stern.jpg'
      when 2...3
        @grade = 'B'
        @mom_picture = 'mom-unhappy.jpg'
      else
        @grade = 'A'
        @mom_picture = 'mom-happy.jpg'
    end
  end

  def score_total_outbound_calls
    return PhoneCall.where('created_at > ? and inbound = false', Time.now()-604800).count
  end

  def score_total_seconds
    return PhoneCall.where('created_at > ? and missed_call is not true', Time.now()-604800).sum('duration')
  end

  def score_average_response_time
    phone_calls = PhoneCall.where('created_at > ? and inbound = true and missed_call = true', Time.now()-604800)
    sum = 0
    for pc in phone_calls
      pc.response_time.nil? ? (sum += (Time.now() - pc.created_at)) : (sum += pc.response_time)
    end
    sum == 0 ? (return 86400) : (return sum / phone_calls.count)
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
#      elsif params['From'] == MOM  # TODO think this through. would like to restrict this to MOM but her number is blocked
      else
        # mom --> son
        counterparty = SON
        direction = 'inbound'
        name = 'Mom'
      end

      pc = PhoneCall.new(:direction => direction, :duration => 0, :call_sid => params['CallSid'])
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
                                    :url => 'http://callmom.herokuapp.com/mom',
                                  :status_callback => 'http://callmom.herokuapp.com/mom/call_ended',
                                    :if_machine => 'hangup'
                                  })
    render :text => 'OK'
  end

  def logs
    @phone_calls = PhoneCall.order(:created_at).reverse_order
  end

  def test
    # set up a client to talk to the Twilio REST API
    account_sid = 'AC2c0c745ec4d44b2e8c34ce702d81dadd'
    auth_token = '4c8d9d87c5e4b1f0634a6a27e9bc9300'
    @client = Twilio::REST::Client.new account_sid, auth_token

    # build up a response
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'hey buddy', :voice => 'woman'
    end

    render :xml => response.text
  end

end
