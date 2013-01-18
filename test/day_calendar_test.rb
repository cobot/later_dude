require_relative './test_helper'
require 'nokogiri'

I18n.load_path += Dir[File.expand_path('fixtures/locales', File.dirname(__FILE__)) + '/*.yml']

class DayCalendarTest < ActiveSupport::TestCase
  setup do
    I18n.locale = 'en'
  end

  test 'renders a day' do
    day = Nokogiri::HTML LaterDude::Calendar.new({year: 2013, month: 1, day: 1}).to_html

    assert_equal %w(1), day.css('tbody td').map(&:text)
  end

  test 'renders the date' do
    day = Nokogiri::HTML LaterDude::Calendar.new({year: 2012, month: 1, day: 1}).to_html

    assert_equal ['Jan 01'], day.css('thead tr.day_names th').map(&:text)
  end

  test 'renders the contents of the block when passed to to_html' do
    html = LaterDude::Calendar.new({year: 2012, month: 1, day: 1}).to_html {'a day'}
    day = Nokogiri::HTML html

    assert_equal ['a day'], day.css('tbody td').map{|td| td.text}
  end

  test 'renders the contents of the block when passed to initialize' do
    html = (LaterDude::Calendar.new({year: 2012, month: 1, day: 1}) {'a day'}).to_html
    day = Nokogiri::HTML html

    assert_equal ['a day'], day.css('tbody td').map{|td| td.text}
  end
end
