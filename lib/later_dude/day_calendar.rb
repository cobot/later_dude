module LaterDude
  class DayCalendar
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper

    attr_accessor :output_buffer, :block

    def initialize(year, month, day, options = {}, &block)
      @year, @month, @day, @options = year, month, day, options
      @date = Date.civil(year, month, day)
      @block = block
    end

    def show_names
      content_tag(:tr, @date.to_s, :class => 'day_names') do
        content_tag(:th, I18n.l(@date, format: :short))
      end
    end

    def show_days
      @block ||= block
      content_tag(:tr, show_day(@date).html_safe)
    end

    private

    def show_day(day)
      DayRenderer.new(day).to_html(&@block)
    end
  end
end
