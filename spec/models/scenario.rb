require File.dirname(__FILE__) + "/../spec_helper.rb"
require_relative "../../models/scenario"

describe Scenario do
  it "should format url with dates" do
    scenario = Scenario.new
    scenario.url = '{{ this_friday | date: "%A" }}'
    expect(scenario.test_url).to end_with("Friday")
  end

  it "should allow date addition in url with dates" do
    scenario = Scenario.new
    scenario.url = '{{ this_friday | add_days: 1 | date: "%A" }}'
    expect(scenario.test_url).to end_with("Saturday")
  end

  it "should return correct url for IE9 tests" do
    scenario = Scenario.new
    scenario.url = 'abc'
    scenario.domelement = 'card1'
    scenario.location_region = "US_East"
    expect(scenario.test_url).to end_with("runtest.php?runs=1&f=xml&fvonly=1&mobile=0&location=US_East.Cable&domelement=card1&url=abc")
  end

  it "should return correct url for Chrome tests" do
    scenario = Scenario.new
    scenario.url = 'abc'
    scenario.domelement = 'card1'
    scenario.browser = 'Chrome'
    scenario.location_region = "US_East"
    expect(scenario.test_url).to end_with("runtest.php?runs=1&f=xml&fvonly=1&mobile=0&location=US_East_wptdriver:Chrome.Cable&domelement=card1&url=abc")
  end

  it "should return correct url for Mobile tests" do
    scenario = Scenario.new
    scenario.url = 'abc'
    scenario.domelement = 'card1'
    scenario.browser = 'Mobile'
    scenario.location_region = "US_East"
    expect(scenario.test_url).to end_with("runtest.php?runs=1&f=xml&fvonly=1&mobile=1&location=US_East_wptdriver:Chrome.Cable&domelement=card1&url=abc")
  end
end
