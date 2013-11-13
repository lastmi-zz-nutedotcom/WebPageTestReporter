require 'csv'

module Reporter
  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers

    enable :sessions

    layout :layout

    get '/' do
      @nav_selected = :index
      erb :index
    end

    get '/index' do
      @nav_selected = :index
      erb :index
    end

    get '/summary' do
      @scenario_groups = ScenarioGroup.all
      @current_scenario_group_id = params['scenario_group_id'] || @scenario_groups[0].id.to_s
      @scenarios = Scenario.for_display.where(:scenario_group_id => @current_scenario_group_id).order_by(:scenario_id.asc)
      @nav_selected = :summary
      erb :summary
    end

    get '/compare' do
      @scenario_groups = ScenarioGroup.all
      @current_scenario_group_id = params['scenario_group_id'] || @scenario_groups[0].id.to_s
      @scenarios = Scenario.for_display.where(:scenario_group_id => @current_scenario_group_id).order_by(:scenario_id.asc)
      @nav_selected = :compare
      erb :compare
    end

    get '/analyse' do
      @scenario_groups = ScenarioGroup.all
      @current_scenario_group_id = params['scenario_group_id'] || @scenario_groups[0].id.to_s
      @scenarios = Scenario.for_display.where(:scenario_group_id => @current_scenario_group_id).order_by(:scenario_id.asc)

      @scenario_id = params['scenario']
      if @scenario_id != "" && @scenario_id != nil
        test_result = TestResult.where(:scenario_id => @scenario_id).order_by(:time_of_test.desc).limit(1)
        @objects = ObjectDownload.where(:time_of_test => test_result.first.time_of_test).where(:scenario_id => @scenario_id)
      end
      @nav_selected = :analyse
      erb :analyse
    end

    get '/object_times.csv' do
      response.headers["Access-Control-Allow-Origin"] = "*"

      CSV.generate do |csv|
        ObjectDownload.where(:scenario_id => params['scenario']).where(:object_url => params['url']).order_by(:time_of_test.asc).each do |download|
          csv << [download.time_of_test.getgm.strftime('%FT%R:%S'), download.time_to_download, download.time_to_first_byte, download.time_to_connect, download.dns_time]
        end
      end
    end

    get '/results.csv' do
      response.headers["Access-Control-Allow-Origin"] = "*"

      CSV.generate do |csv|
        TestResult.where(:scenario_id => params['scenario']).order_by(:time_of_test.asc).each do |result|
          csv << [result.time_of_test.getgm.strftime('%FT%R:%S'), result.time_to_first_byte, result.time_to_atf, result.time_to_atf - result.time_to_first_byte]
        end
      end
    end

    get '/compare_results.csv' do
      response.headers["Access-Control-Allow-Origin"] = "*"
      scenarios = params['scenarios'].split(',')
      graph_type = params['graph_type'].to_sym

      CSV.generate do |csv|
        TestResult.in(:scenario_id => scenarios).order_by(:time_of_test.asc).each do |result|
          row = ([result.time_of_test.getgm.strftime('%FT%R:%S')] << ([nil] * scenarios.count)).flatten
          value = case graph_type
          when :client_side
            result.time_to_atf - result.time_to_first_byte
          else
            result[graph_type]
          end
          row[scenarios.index(result.scenario_id.to_s) + 1] = value
          csv << row
        end
      end
    end

    get '/show_details' do
        result = TestResult.where(:scenario_id => params['scenario']).where(:time_of_test => Time.at(params['time'].to_i/1000).to_s).first
        if result != nil
            csv_url = result.csv_url
            url = csv_url.gsub("page_data.csv","1/details/").gsub("http://localhost/",Padrino.mounted_apps[0].app_obj.web_page_test_url)
            redirect url
        end
    end

  end
end
