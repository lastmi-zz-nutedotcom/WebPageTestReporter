class TestResult
        include Mongoid::Document

        field :scenario_id, type: String
        field :time_of_test, type: Time
        field :load_time, type: Integer
        field :time_to_first_byte, type: Integer
        field :time_to_dom_element, type: Integer
        field :time_to_atf_user_timing, type: Integer
        field :csv_url, type: String
        field :browser, type: String
        field :connection_speed, type: String
        field :location, type: String

        index({ time_of_test: 1 })
        index({ scenario_id: 1 })

        def time_to_atf
              time_to_dom_element || time_to_atf_user_timing || 0
        end 
end