module LaterDude
  # TODO: Maybe make output prettier?
  class Calendar
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper

    attr_accessor :output_buffer
    attr_reader :renderer

    delegate :first_rendered_date, :last_rendered_date, to: :renderer

    # params:
    #         either: year, month, options
    #         or    : {year: <year>, <week|day|month>: <week|day|month>}, options
    def initialize(*args, &block)
      if (date_options = args.first).is_a?(Hash)
        year = date_options[:year]
        month = date_options[:month]
        week = date_options[:week]
        day = date_options[:day]
        options = args[1]
      else
        year, month = args[0], args[1]
        options = args[2]
        raise ArgumentError.new("Need to pass in year and month") unless year && month
      end
      @options = (options || {}).symbolize_keys.reverse_merge(self.class.default_calendar_options)

      @renderer = if day
        DayCalendar.new year, month, day, @options, &block
      elsif week
        WeekCalendar.new year, week, @options, &block
      else
        MonthCalendar.new year, month, @options, &block
      end
    end

    def to_html(&block)
      renderer.block = block if block_given?
      content_tag(:table, :class => "#{@options[:calendar_class]}") do
        content_tag(:thead, renderer.show_names) +
          content_tag(:tbody, renderer.show_days(&block))
      end
    end


    class << self
      def weekend?(day)
        [0,6].include?(day.wday) # 0 = Sunday, 6 = Saturday
      end

      def default_calendar_options
        {
          :calendar_class => "calendar",
          :first_day_of_week => I18n.translate(:'date.first_day_of_week', :default => "0").to_i,
          :hide_day_names => false,
          :hide_month_name => false,
          :use_full_day_names => false,
          :current_month => I18n.translate(:'date.formats.calendar_header', :default => "%B"),
          :next_month => false,
          :previous_month => false,
          :next_and_previous_month => false,
          :yield_surrounding_days => false
        }
      end

      def full_day_names
        @full_day_names ||= I18n.translate(:'date.day_names')
      end

      def abbreviated_day_names
        @abbreviated_day_names ||= I18n.translate(:'date.abbr_day_names')
      end
    end
  end
end
