class PhoneCall < ActiveRecord::Base
  validates_uniqueness_of :call_sid, :case_sensitive => true
  validates :duration, :response_time, :numericality => { :only_integer => true }, :allow_nil => true

  def inbound=(direction)
    inbound = nil
    case direction
    when 'outbound-api'
      inbound = false
    when 'outbound-dial'
      inbound = false
    when 'inbound'
      inbound = true
    end
    write_attribute(:inbound, inbound)
  end

  def inbound
    direction = 'none'
    if read_attribute(:inbound) == true
      direction = 'inbound'
    else
      direction = 'outbound'
    end
    direction
  end

  def missed?
    return read_attribute(:status) == 'no-answer'
  end

end
