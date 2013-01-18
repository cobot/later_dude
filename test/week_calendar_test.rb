require_relative './test_helper'
require 'nokogiri'

I18n.load_path += Dir[File.expand_path('fixtures/locales', File.dirname(__FILE__)) + '/*.yml']

class WeekCalendarTest < ActiveSupport::TestCase
  setup do
    I18n.locale = 'en'
  end

  test "renders monday to sunday if first_day_of_week is 1" do
    week = Nokogiri::HTML LaterDude::Calendar.new({year: 2012, week: 1}, first_day_of_week: 1).to_html

    assert_equal %w(2 3 4 5 6 7 8), week.css('tbody td').map(&:text)
  end

  test "renders sunday to saturday if first_day_of_week is 0" do
    week = Nokogiri::HTML LaterDude::Calendar.new({year: 2012, week: 1}, first_day_of_week: 0).to_html

    assert_equal %w(1 2 3 4 5 6 7), week.css('tbody td').map(&:text)
  end

  test 'renders the week day names with first_day_of_week = 1' do
    week = Nokogiri::HTML LaterDude::Calendar.new({year: 2012, week: 1}, first_day_of_week: 1).to_html

    assert_equal %w(Mon Tue Wed Thu Fri Sat Sun), week.css('thead tr.week_names th').map(&:text)
  end

  test 'renders the week day names with first_day_of_week = 0' do
    week = Nokogiri::HTML LaterDude::Calendar.new({year: 2012, week: 1}, first_day_of_week: 0).to_html

    assert_equal %w(Sun Mon Tue Wed Thu Fri Sat), week.css('thead tr.week_names th').map(&:text)
  end

  test 'renders the contents of the block when passed to to_html' do
    html = LaterDude::Calendar.new({year: 2012, week: 1}).to_html {'week'}
    week = Nokogiri::HTML html

    assert_equal %w(week) * 7, week.css('tbody td').map{|td| td.text}
  end

  test 'renders the contents of the block when passed to initialize' do
    html = (LaterDude::Calendar.new({year: 2012, week: 1}) {'week'}).to_html
    week = Nokogiri::HTML html

    assert_equal %w(week) * 7, week.css('tbody td').map{|td| td.text}
  end
end
