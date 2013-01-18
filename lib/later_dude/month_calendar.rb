module LaterDude
  class MonthCalendar
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    attr_accessor :output_buffer, :block

    def initialize(year, month, options = {}, &block)
      @year, @month, @options = year, month, options
      # next_month and previous_month take precedence over next_and_previous_month
      @options[:next_month]     ||= @options[:next_and_previous_month]
      @options[:previous_month] ||= @options[:next_and_previous_month]

      @days = Date.civil(@year, @month, 1)..Date.civil(@year, @month, -1)
      @block = block
    end

    def first_rendered_date
      beginning_of_week(@days.first)
    end

    def last_rendered_date
      beginning_of_week(@days.last + 1.week) - 1
    end

    def show_days
      content_tag(:tr, "#{show_previous_month}#{show_current_month}#{show_following_month}".html_safe)
    end

    def show_names
      "#{show_month_names}#{show_day_names}".html_safe
    end

    private

    def show_month_names
      return if @options[:hide_month_name]

      content_tag(:tr, "#{previous_month}#{current_month}#{next_month}".html_safe, :class => 'month_names')
    end

    def show_day_names
      return if @options[:hide_day_names]
      content_tag(:tr, :class => 'day_names') do
        apply_first_day_of_week(day_names).inject('') do |output, day|
          output << content_tag(:th, include_day_abbreviation(day), :scope => 'col', :class => Date::DAYNAMES[day_names.index(day)].downcase)
        end.html_safe
      end
    end

    def show_previous_month
      return if @days.first.wday == first_day_of_week # don't display anything if the first day is the first day of a week

      "".tap do |output|
        beginning_of_week(@days.first).upto(@days.first - 1) { |d| output << show_day(d) }
      end.html_safe
    end

    def show_current_month
      "".tap do |output|
        @days.first.upto(@days.last) { |d| output << show_day(d) }
      end.html_safe
    end

    def show_following_month
      return if @days.last.wday == last_day_of_week # don't display anything if the last day is the last day of a week

      "".tap do |output|
        (@days.last + 1).upto(beginning_of_week(@days.last + 1.week) - 1) { |d| output << show_day(d) }
      end.html_safe
    end

    def show_day(day)
      content = ''
      renderer = DayRenderer.new(day)
      options = {}
      options[:class] = "otherMonth" if day.month != @days.first.month
      if @block && (@options[:yield_surrounding_days] || day.month == @days.first.month)
        content = renderer.to_html options, &@block
      else
        content = renderer.to_html options
      end

      # close table row at the end of a week and start a new one
      # opening and closing tag for the first and last week are included in #show_days
      content << "</tr><tr>".html_safe if day < @days.last && day.wday == last_day_of_week
      content
    end

    def beginning_of_week(day)
      diff = day.wday - first_day_of_week
      diff += 7 if first_day_of_week > day.wday # hackish ;-)
      day - diff
    end

    # @options[:previous_month] can either be a single value or an array containing two values. For a single value, the
    # value can either be a strftime compatible string or a proc.
    # For an array, the first value is considered to be a strftime compatible string and the second is considered to be
    # a proc. If the second value is not a proc then it will be ignored.
    def previous_month
      return unless @options[:previous_month]

      show_month(@days.first - 1.month, @options[:previous_month], :class => "previous")
    end

    # see previous_month
    def next_month
      return unless @options[:next_month]

      show_month(@days.first + 1.month, @options[:next_month], :class => "next")
    end

    # see previous_month and next_month
    def current_month
      colspan = @options[:previous_month] || @options[:next_month] ? 3 : 7 # span across all 7 days if previous and next month aren't shown

      show_month(@days.first, @options[:current_month], :colspan => colspan, :class => "current")
    end

    def show_month(month, format, options={})
      options[:colspan] ||= 2

      content_tag(:th, :colspan => options[:colspan], :class => "#{options[:class]} #{Date::MONTHNAMES[month.month].downcase}") do
        if format.kind_of?(Array) && format.size == 2
          text = I18n.localize(month, :format => format.first.to_s).html_safe
          format.last.respond_to?(:call) ? link_to(text, format.last.call(month)) : text
        else
          format.respond_to?(:call) ? format.call(month) : I18n.localize(month, :format => format.to_s)
        end.html_safe
      end
    end

    def day_names
      @day_names ||= @options[:use_full_day_names] ? Calendar.full_day_names : Calendar.abbreviated_day_names
    end

    # => <abbr title="Sunday">Sun</abbr>
    def include_day_abbreviation(day)
      return day if @options[:use_full_day_names]

      content_tag(:abbr, day, :title => Calendar.full_day_names[Calendar.abbreviated_day_names.index(day)])
    end

    def apply_first_day_of_week(day_names)
      names = day_names.dup
      first_day_of_week.times { names.push(names.shift) }
      names
    end

    def first_day_of_week
      @options[:first_day_of_week]
    end

    def last_day_of_week
      @options[:first_day_of_week] > 0 ? @options[:first_day_of_week] - 1 : 6
    end

  end
end
