require 'date'

class DateRangeGenerator
  
  def generate(start_date, end_date)
    start_date = Date.parse(start_date)
    end_date = Date.parse(end_date)

    (start_date..end_date)
  end


end