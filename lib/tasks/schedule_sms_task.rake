namespace :db do 
	desc "Calculate Score at 8:00 am daily and send SMS"
	task :schedule_sms_task => :environment do
		@users = User.all
		debugger
		unless @users.nil?
			@users.each do |user|
					
	    	    if Time.now.strftime("%H:%M %p") == "22:20 PM"
	    	    	@total_outbound = score_total_outbound_calls(user)
	      			@total_seconds = score_total_seconds(user)
	      			@average_response_time = score_average_response_time(user)
				    user_score = @total_outbound/3.to_f + @total_seconds/3600.to_f + 86400/@average_response_time.to_f

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

					if user_score == user_score + 1
						
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
	    			elsif user_score == user_score -1
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


		def score_total_outbound_calls(user)
	    	return PhoneCall.where("created_at > '%s' and system_number = '%s' and inbound = false", Time.now()-604800, user.system_number).count
	  	end

	  	def score_total_seconds(user)
	    	return PhoneCall.where("created_at > '%s' and system_number = '%s' and missed_call is not true", Time.now()-604800, user.system_number).sum('duration')
	  	end
	  
	  	def score_average_response_time(user)
	    	phone_calls = PhoneCall.where("created_at > '%s' and system_number = '%s' and inbound = true and missed_call = true", Time.now()-604800, user.system_number)
	    	sum = 0
	    	for pc in phone_calls
	      		pc.response_time.nil? ? (sum += (Time.now() - pc.created_at)) : (sum += pc.response_time)
	    	end
	    	sum == 0 ? (return 86400) : (return sum / phone_calls.count)
	  	end
	end	
end 