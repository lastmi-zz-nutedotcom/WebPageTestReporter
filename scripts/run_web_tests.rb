#!/usr/bin/env ruby
require "net/http"
require "uri"
require "nokogiri"
require "csv"
require "pry"
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

class TestSpeed
	def self.make_request (scenario)
		test_result = TestResult.new ({
			:scenario_id => scenario.scenario_id,
			:browser => scenario.browser,
			:location => scenario.location_region,
			:connection_speed => scenario.connection_speed,
		})

		test_url = scenario.test_url
		puts "#{Time.new}: Requesting scenario id #{scenario.scenario_id} - #{test_url}"

		response = Net::HTTP.get(URI(test_url))
		doc  = Nokogiri::XML(response)
		csv_url = doc.at_xpath('//summaryCSV').content
		puts "#{Time.new}: Waiting for csv results be become available at url - #{csv_url}"
		uri = URI.parse(csv_url)
		http = Net::HTTP.new(uri.host, uri.port)

		req = Net::HTTP::Post.new(uri.path)

		while((csv_content = http.request(req)).class == Net::HTTPNotFound)
			sleep 5
		end

		raw_results = CSV.parse(csv_content.body, {:headers => true, :return_headers => true, :header_converters => :symbol, :converters => :all})
        json_url = doc.at_xpath('//jsonUrl').content
        json_url = json_url[0,json_url.size-1]
        result_json = JSON.parse(Net::HTTP.get(URI(json_url)))

        test_result.time_of_test = raw_results[1][:time]
        test_result.load_time = raw_results[1][:load_time_ms]
        test_result.time_to_first_byte = raw_results[1][:time_to_first_byte_ms]
        test_result.time_to_dom_element = raw_results[1][:time_to_dom_element_ms]
        test_result.time_to_atf_user_timing = result_json['data']['runs'][1]['firstView']['userTime.above_the_fold_rendered']
        test_result.csv_url = csv_url
        test_result.save

        save_object_stats(result_json, test_result)

        puts "#{Time.new}: Succeeded testing scenarion id #{scenario.scenario_id}"
	end

	def self.save_object_stats(result_json, test_result)
		objects = []
		result_json['data']['runs'][1]['firstView']['requests'].each { |request|
			if test_result.time_to_atf && request['all_start'].to_i < test_result.time_to_atf
				objects << ObjectDownload.new.tap { |obj|
					obj.time_of_test = test_result.time_of_test
					obj.scenario_id = test_result.scenario_id

					obj.object_url = request['host'] + request['url'].split('?')[0].split('&')[0].split('451703/')[0].split('http://')[0]
					obj.load_start = request['load_start']
					obj.download_end = request['all_end']
					obj.time_to_first_byte = request['ttfb_ms']
					obj.dns_time = request['dns_ms']
					obj.time_to_connect = request['connect_ms']
					obj.time_to_download = request['download_ms']
				}
			end
		}
		objects.each do |obj|
			download_count = 0
			objects.each do |other_obj|
				if obj.load_start.between?(other_obj.load_start, other_obj.download_end)
					download_count = download_count + 1
				end 
			end
			obj.download_count = download_count
			obj.save
		end
	end
end

def run_tests
	puts "#{Time.new}: Checking for tests to run..."
	Scenario.tests_to_run.each do |scenario|
		begin
		    TestSpeed.make_request scenario
		    scenario.next_run_time = Time.new + (scenario.run_interval * 60)
            scenario.save
		rescue StandardError => e
		    puts "#{Time.new}: Failure running scenario: #{scenario.scenario_id}"	
		    puts e.inspect
		    puts e.backtrace
		end
	end
end

run_tests
