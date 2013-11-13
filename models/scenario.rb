require "chronic"

class ScenarioGroup
    include Mongoid::Document

    has_many :scenario

    field :name, type: String
end

class Scenario	
	include Mongoid::Document

    belongs_to :scenario_group

    scope :enabled, where(:enabled_for_capture => true)
    scope :for_display, where(:include_in_reports => true)
    scope :tests_to_run, where(:enabled_for_capture => true).lt(:next_run_time => Time.new)

    field :scenario_id, type: String
    field :description, type: String
    field :url, type: String
    field :location_region, type: String, default: "US_East"
    field :connection_speed, type: String, default: "Cable"
    field :domelement, type: String
    field :browser, type: String, default: "IE9"
    field :next_run_time, type: Time, default: Time.new
    field :run_interval, type: Integer, default: 30
    field :enabled_for_capture, type: Boolean, default: true 
    field :include_in_reports, type: Boolean, default: true

    module AddDaysFilter
	  def add_days(date, number_days)
	    date + number_days * 60 * 60 * 24
	  end
	end

    def page_url
        vars = {
            'this_friday' => Chronic.parse("this Friday"),
            'this_saturday' => Chronic.parse("this Saturday")
        }
        Liquid::Template.parse(url).render(vars, :filters => [AddDaysFilter])
    end

    def test_url
        encoded_page_url = URI.escape(page_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        location_value = 
        mobile_value = (browser == "Mobile" ? "1" : "0")
        location_value = case browser
            when "IE9"
                location_region
            when "Chrome", "Mobile"
                location_region << "_wptdriver:Chrome"
            end 
        "http://localhost/runtest.php?runs=1&f=xml&fvonly=1&mobile=#{mobile_value}&location=#{location_value}.#{connection_speed}&domelement=#{domelement}&url=#{encoded_page_url}"
    end
end
