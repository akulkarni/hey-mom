class GradeController < ApplicationController

  def index
    @total_outbound = score_total_outbound_calls()
    @total_seconds = score_total_seconds()
    @average_response_time = score_average_response_time()

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

end
