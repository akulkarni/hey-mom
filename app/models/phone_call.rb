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

end
