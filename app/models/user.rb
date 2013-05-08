class User < ActiveRecord::Base
  
  attr_accessor :current_call_score

  attr_accessible :contact_name, :contact_phone_number, :name, :phone_number, :system_number, :current_call_score
 

	  

  def current_score
  	total_outbound = PhoneCall.score_total_outbound_calls(self)
    total_seconds = PhoneCall.score_total_seconds(self)
    average_response_time = PhoneCall.score_average_response_time(self)
    self.current_call_score = total_outbound/3.to_f + total_seconds/3600.to_f + 86400/average_response_time.to_f
  end


end
