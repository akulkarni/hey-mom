namespace :db do 
	desc "Calculate Score at 8:00 am daily and send SMS"
	task :schedule_sms_task => :environment do
    
		@users = User.all
		
		unless @users.nil?
			@users.each do |user|
				# @total_outbound = PhoneCall.score_total_outbound_calls(user)
    #   	@total_seconds = PhoneCall.score_total_seconds(user)
    #   	@average_response_time = PhoneCall.score_average_response_time(user)
		  user_score = user.current_score #@total_outbound/3.to_f + @total_seconds/3600.to_f + 86400/@average_response_time.to_f

    			case user_score
    				when 0...2
      				@grade = 'F'
      			when 2...3
      				@grade = 'B'
			    else
			    	@grade = 'A'
			    end
				  
			  account_sid = 'AC2c0c745ec4d44b2e8c34ce702d81dadd'
  			auth_token = '4c8d9d87c5e4b1f0634a6a27e9bc9300'
  			
      
        @client = Twilio::REST::Client.new account_sid, auth_token
		
  		    #puts user_score ==  user.current_call_score ? "Both are the same values." : "Go Ahead"
          if user_score < user.current_call_score
      	    #Message to mom
  			    @client.account.account.sms.messages.create(
    					:from => ENV['HEYMOM_HOST'],
    					:to => user.contact_phone_number,
    					:body => "Hey #{user.contact_name}! #{user.name} just improved to a #{@grade}. Now stop giving them such a hard time. #{@grade}"
  				  )
  			    #Message to son
  			    @client.account.account.sms.messages.create(
    					:from => ENV['HEYMOM_HOST'],
    					:to => user.phone_number,
    					:body => "Hey #{user.name}, you just improved to a #{@grade}. And we just sent the proof to #{user.contact_name}. Keep up the good work. #{@grade}"
  				  )
          end

          if user_score > user.current_call_score
  				  #Message to mom
  			    @client.account.account.sms.messages.create(
    					:from => ENV['HEYMOM_HOST'],
    					:to => user.contact_phone_number,
    					:body => "Uh oh. #{user.name} just scored a #{@grade}. But they're trying, we promise. #{@grade}"
  				  )
  			    #Message to son
  			    @client.account.account.sms.messages.create(
    					:from => ENV['HEYMOM_HOST'],
    					:to => user.phone_number,
    					:body => "Hey. You just dropped to a #{@grade}. Call #{user.contact_name}. Like, right now. #{@grade}"
  				  )
          end
			end
		end


		
	end	
end 