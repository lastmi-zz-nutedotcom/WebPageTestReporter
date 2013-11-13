#!/usr/bin/env ruby
require 'fileutils'

months_to_keep = 1
current_month = Time.new.month

Dir.glob("/var/www/html/results/#{Time.new.year.to_s[2..3]}/*").select do |f|
        folder_month = File.basename(f).to_i
        diff_months = (current_month - folder_month) % 12
        if diff_months > months_to_keep
			FileUtils.rm_rf(f)
        end
end

#remove any left over from last year
if current_month - months_to_keep > 0
	Dir.glob("/var/www/html/results/#{(Time.new.year-1).to_s[2..3]}").select do |f|
		FileUtils.rm_rf(f)
    end
end