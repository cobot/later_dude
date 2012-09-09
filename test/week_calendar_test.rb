require 'test_helper'
require 'nokogiri'

I18n.load_path += Dir[File.expand_path('fixtures/locales', File.dirname(__FILE__)) + '/*.yml']

class WeekCalendarTest < ActiveSupport::TestCase
  setup do
    I18n.locale = 'en'
  end

  test "renders monday to sunday if first_day_of_week is 1" do
    week = Nokogiri::HTML LaterDude::Calendar.new({year: 2012, week: 1}, first_day_of_week: 1).to_html

    assert_equal %w(2 3 4 5 6 7 8), week.css('td').map(&:text)
  end

  test "renders sunday to saturday if first_day_if_week is 0" do
    week = Nokogiri::HTML LaterDude::Calendar.new({year: 2012, week: 1}, first_day_of_week: 0).to_html

    assert_equal %w(1 2 3 4 5 6 7), week.css('td').map(&:text)
  end

  test 'renders the contents of the block' do
    html = LaterDude::Calendar.new({year: 2012, week: 1}).to_html {'week'}
    week = Nokogiri::HTML html

    assert_equal %w(week) * 7, week.css('td').map{|td| td.text[/week/]}
  end
end
