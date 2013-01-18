require_relative './test_helper'

class CalendarHelperTest < ActiveSupport::TestCase
  setup do
    @helper = Object.new
    class << @helper
      include LaterDude::CalendarHelper
    end
  end

  test "requires year and month" do
    assert_raises(ArgumentError) { @helper.calendar_for }
    assert_raises(ArgumentError) { @helper.calendar_for(2009) }
    assert_nothing_raised { @helper.calendar_for(2009, 1) }
  end

  test "accepts optional options hash" do
    options = { :calendar_class => "my_calendar", :first_day_of_week => 1 }
    assert_nothing_raised { @helper.calendar_for(2009, 1, options) }
  end

  test "accepts hash instead of year and month" do
    assert_nothing_raised { @helper.calendar_for({year: 2009, month: 1}, {}) }
  end

  test "accepts optional block" do
    options = { :calendar_class => "my_calendar", :first_day_of_week => 1 }
    some_block = lambda { |day| nil }

    assert_nothing_raised { @helper.calendar_for(2009, 1, &some_block) }
    assert_nothing_raised { @helper.calendar_for(2009, 1, options, &some_block) }
  end
end
