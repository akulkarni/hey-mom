class CallController < ApplicationController
  SON = '+19175731568'
  MOM = '+19739794384'

  def ok
    render :text => 'OK'
  end

  def index
    return ok
  end

  def create
    unless params['AccountSid'].nil?

      if params['From'] == SON
        # son --> mom
        counterparty = MOM
        direction = 'outbound'
        name = 'Ajay'
      else
        # mom --> son
        counterparty = SON
        direction = 'inbound'
        name = 'Mom'
      end

      pc = PhoneCall.new(:direction => direction, :duration => 0, :call_sid => params['CallSid'])
      pc.save!

      # build up a response
      system_number = params['To']
      greeting = 'Hi %s, connecting you right now.' % name
      response = Twilio::TwiML::Response.new do |r|
        r.Say greeting, :voice => 'woman'
        r.Dial :callerId => system_number do |d|
          d.Number counterparty
        end
      end

      render :xml => response.text
    else
      render :text => params
    end

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

  def logs
    @phone_calls = PhoneCall.order(:created_at).reverse_order
  end

end
