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
      r.Say 'hello there', :voice => 'woman'
      r.Dial :callerId => '+14159992222' do |d|
        d.Client 'jenny'
      end
    end

    render :xml => response.text
  end
end
