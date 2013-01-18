module LaterDude
  module CalendarHelper
    def calendar_for(*args, &block)
      Calendar.new(*args, &block).to_html
    end
  end
end
