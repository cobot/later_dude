require 'action_view'
require 'action_view/helpers'
require 'action_view/helpers/capture_helper'
require 'action_view/helpers/tag_helper'
require 'action_view/helpers/url_helper'

begin
  require 'active_support/core_ext/date/acts_like'
  require 'active_support/core_ext/date_time/acts_like'
  require 'active_support/core_ext/time/acts_like'

  require 'active_support/core_ext/integer/time'
  require 'active_support/core_ext/numeric/time'
rescue LoadError
  # nothing
end


require 'later_dude/rails2_compat'

require 'later_dude/railtie' if defined? Rails::Railtie

module LaterDude
  autoload :Calendar, 'later_dude/calendar'
  autoload :MonthCalendar, 'later_dude/month_calendar'
  autoload :WeekCalendar, 'later_dude/week_calendar'
  autoload :DayCalendar, 'later_dude/day_calendar'
  autoload :CalendarHelper, 'later_dude/calendar_helper'
end
