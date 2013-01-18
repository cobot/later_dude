module LaterDude
  class DayRenderer
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper

    def initialize(date)
      @date = date
    end

    def to_html(options = {}, &block)
      options[:class] ||= ""
      options[:class] << " day"
      options[:class] << " weekend" if Calendar.weekend?(@date)
      options[:class] << " today" if @date.today?
      options[:class].strip!

      # block is only called for current month or if :yield_surrounding_days is set to true
      if block
        content, options_from_block = Array(block.call(@date))

        # passing options is optional
        if options_from_block.is_a?(Hash)
          options[:class] << " #{options_from_block.delete(:class)}" if options_from_block[:class]
          options.merge!(options_from_block)
        end
      else
        content = @date.day
      end

      content_tag(:td, content.to_s.html_safe, options)
    end
  end
end
