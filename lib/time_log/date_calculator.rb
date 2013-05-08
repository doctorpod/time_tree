require 'date'

module TimeLog
  module DateCalculator
    def prev_weekday(date, weekday, count = 0)
      delta = (7 + date.wday - daynum(weekday)) % 7
      date - (delta + (count * 7))
    end

    def next_weekday(date, weekday, count = 0)
      delta = (7 - date.wday + daynum(weekday)) % 7
      delta = 7 if delta == 0
      date + (delta + (count * 7))
    end
  
    def date_between?(date, from, to)
      date >= from && to >= date
    end
    
    def in_prev_week?(date, count = 0, ref_date = Date.today)
      monday = prev_weekday(ref_date, :mon, count)
      sunday = monday + 6
      date_between?(date, monday, sunday)
    end
    
    def in_prev_month?(date, count = 0, ref_date = Date.today)
      ref_month = ref_date >> (-1 * count)
      date.year == ref_month.year && date.month == ref_month.month
    end
  
    private
  
    def daynum(weekday)
      {:mon => 1, :tue => 2, :wed => 3, :thu => 4, :fri => 5, :sat => 6, :sun => 7}[weekday]
    end
  end
end
