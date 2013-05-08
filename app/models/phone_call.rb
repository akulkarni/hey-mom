class PhoneCall < ActiveRecord::Base
  

  validates_uniqueness_of :call_sid, :case_sensitive => true
  validates :duration, :response_time, :numericality => { :only_integer => true }, :allow_nil => true

  def direction=(direction)
    inbound = nil
    case direction
    when 'outbound-api'
      inbound = false
    when 'outbound-dial'
      inbound = false
    when 'outbound'
      inbound = false
    when 'inbound'
      inbound = true
    end
    write_attribute(:inbound, inbound)
  end

  def direction
    direction = 'none'
    if read_attribute(:inbound) == true
      direction = 'inbound'
    else
      direction = 'outbound'
    end
    direction
  end

  #score calculation

  
  def self.score_total_outbound_calls(user)
    return where("created_at > '%s' and system_number = '%s' and inbound = false", Time.now()-604800, user.system_number).count
  end

  def self.score_total_seconds(user)
    return where("created_at > '%s' and system_number = '%s' and missed_call is not true", Time.now()-604800, user.system_number).sum('duration')
  end

  def self.score_average_response_time(user)
    phone_calls = where("created_at > '%s' and system_number = '%s' and inbound = true and missed_call = true", Time.now()-604800, user.system_number)
    sum = 0
    for pc in phone_calls
        pc.response_time.nil? ? (sum += (Time.now() - pc.created_at)) : (sum += pc.response_time)
    end
    sum == 0 ? (return 86400) : (return sum / phone_calls.count)
  end

end
