module LaterDude
  class WeekCalendar
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper

    attr_accessor :output_buffer, :block

    # params:
    #        week: 1..52
    def initialize(year, week, options = {}, &block)
      @year, @week, @options = year, week, options
      first_day = Date.civil(year, ((week - 1) * 7 / 12) + 1 + first_day_of_week, ((week - 1) * 7 % 12) + 1 + first_day_of_week)
      @days = first_day..(first_day + 6)
    end

    def show_names
      content_tag(:tr, current_week.html_safe, :class => 'week_names') do
        day_names.map do |name|
          content_tag(:th, name)
        end.join.html_safe
      end
    end

    def show_days(&block)
      @block ||= block
      content_tag(:tr, show_current_week.html_safe)
    end

    private

    def first_day_of_week
      @options[:first_day_of_week]
    end

    def show_current_week
      "".tap do |output|
        @days.first.upto(@days.last) { |d| output << show_day(d) }
      end.html_safe
    end

    def show_day(day)
      options = { :class => "day" }
      options[:class] << " weekend" if Calendar.weekend?(day)
      options[:class] << " today" if day.today?

      if @block
        content, options_from_block = Array(@block.call(day))

        # passing options is optional
        if options_from_block.is_a?(Hash)
          options[:class] << " #{options_from_block.delete(:class)}" if options_from_block[:class]
          options.merge!(options_from_block)
        end
      else
        content = day.day
      end

      content = content_tag(:td, content.to_s.html_safe, options)
      content
    end

    def current_week
      show_week(@days.first, @options[:current_week], :class => "current")
    end

    def show_week(week, format, options = {})
      content_tag(:th, :class => "#{options[:class]} #{week}") do
        I18n.localize(week, :format => format.to_s).html_safe
      end
    end

    def day_names
      @day_names ||= @options[:use_full_day_names] ? Calendar.full_day_names : Calendar.abbreviated_day_names
      if first_day_of_week == 1
        @day_names[1..-1] + [@day_names[0]]
      else
        @day_names
      end
    end
  end
end
