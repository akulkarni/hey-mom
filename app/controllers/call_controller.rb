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
      system_number = params['To']
      user = User.where("system_number = '%s'", system_number).last
      unless user.nil?
        if params['From'] == user.phone_number
          # son --> mom
          direction = 'outbound'
          name = user.name
          counterparty = user.contact_phone_number
        elsif params['From'] == user.contact_phone_number or system_number == '+19177192233' # hack to handle ajay's mom's blocked number
          # mom --> son
          direction = 'inbound'
          name = user.contact_name
          counterparty = user.phone_number
        end

        unless counterparty.nil?
          pc = PhoneCall.new(:direction => direction, :duration => 0, :call_sid => params['CallSid'], :system_number => system_number)
          pc.save!

          # build up a response
          greeting = 'Hi %s, connecting you right now.' % name
          response = Twilio::TwiML::Response.new do |r|
            r.Say greeting, :voice => 'woman'
            r.Dial :callerId => system_number do |d|
              d.Number counterparty
            end
          end
          render :xml => response.text
        else
          greeting = 'Sorry buddy, wrong number.'
          response = Twilio::TwiML::Response.new do |r|
            r.Say greeting, :voice => 'man'
          end
          render :xml => response.text
        end
      else
        render :text => params
      end
    end
  end

  def call_ended
    unless params['CallSid'].nil?
      pc = PhoneCall.where("call_sid = ?", params['CallSid']).last
      unless pc.nil?
        pc.duration = params['CallDuration']
        pc.status = params['CallStatus']
      else
        pc = PhoneCall.new(:inbound => get_inbound(params['To'], params['Caller']), :duration => params['CallDuration'], :call_sid => params['CallSid'], :status => params['CallStatus'], :system_number => params['To'])
      end

      # we don't always know if a call went to voicemail, so we assume short calls were missed
      if (params['AnsweredBy'] == 'machine') or
          ((params['CallDuration'].to_i > 10) and (params['CallDuration'].to_i < 65))
        pc.missed_call = true
        if params['AnsweredBy'] == 'machine'
          # probably a better way to do this
          pc.duration = 0
        end
      end

      pc.save!

      # record response time from the previous call in the other direction
#      pc_prev = PhoneCall.where(:inbound => !pc.inbound).last!
      pc_prev = PhoneCall.where(:inbound => !pc.inbound, :system_number => params['To']).last!
      unless pc_prev.nil?
        pc_prev.response_time = (pc.created_at - pc_prev.created_at).to_i
        pc_prev.save!
      end

    end
    render :text => 'OK'
  end
  
  def get_inbound(system_number, caller_number)
    #    caller_number == AJAY ? (return false) : (return true)
    user = User.where(:system_number => system_number).last
    return caller_number == user.contact_phone_number
  end

end
