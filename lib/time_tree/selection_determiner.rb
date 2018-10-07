module TimeTree
  # Determines if an entry should be included based on options and filters
  module SelectionDeterminer
    extend DateCalculator

    def self.selected?(date, activities = '', options)
      date_options_support_selection?(date, options) &&
        filter_supports_selection?(activities, options)
    end

    def self.date_options_support_selection?(date, options)
      return true if options.detect { |k, _v| date_options.include?(k) }.nil?
      return true if options[:all]
      specific_date_options_support_selection?(options, Date.parse(date))
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def self.specific_date_options_support_selection?(options, parsed_date)
      today_matches?(options, parsed_date) ||
        yesterday_matches?(options, parsed_date) ||
        week_matches?(options, parsed_date) ||
        month_matches?(options, parsed_date) ||
        date_matches?(options, parsed_date) ||
        range_matches?(options, parsed_date) ||
        false
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def self.today_matches?(options, parsed_date)
      options[:today] && parsed_date == Date.today
    end

    def self.yesterday_matches?(options, parsed_date)
      options[:yesterday] && parsed_date == Date.today - 1
    end

    def self.week_matches?(options, parsed_date)
      options[:week] && in_prev_week?(parsed_date, options[:week])
    end

    def self.month_matches?(options, parsed_date)
      options[:month] && in_prev_month?(parsed_date, options[:month])
    end

    def self.date_matches?(options, parsed_date)
      options[:date] && parsed_date == Date.parse(options[:date])
    end

    def self.range_matches?(options, parsed_date)
      options[:range] &&
        parsed_date >= Date.parse(options[:range].split(':').first) &&
        parsed_date <= Date.parse(options[:range].split(':').last)
    end

    def self.date_options
      %i[today yesterday week month date range]
    end

    def self.filter_supports_selection?(activities, options)
      return true if options[:filter].nil?
      options[:filter].any? { |f| activities =~ Regexp.new(f) }
    end
  end
end
