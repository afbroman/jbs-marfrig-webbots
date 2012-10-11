#!/usr/bin/env ruby

require 'curl'
require 'uri'
require 'timeout'

result_dir = "/Users/abroman/Documents/SAGE\ Project/Results/2012.10/"

if ARGV.empty?
  puts "Usage: <filename> <list of sifs>"
  exit
else
  sif_array = ARGV
end

# Build array of legitimate dates (check email from Holly for limits)
#   * check email from Holly for limits (10/1/2008 to 2/29/2012)
#   * look at marfrig code for legitimate dates (marfrig_date_code.html)

# The use of integers & strings here is rather messy. TODO: Fix the use of strings/integer
date_array = Array.new
filename_array = Array.new

year = 2012

  for month in 3..9
    month = "0#{month}" if month < 10
    for day in 1..31
      day = "0#{day}" if day < 10

      
      # Limit April, June, September, and November 
      next if day == 31 && (month == "04" || month == "06" || month == "09")
      
      date_array << "#{day}/#{month}/#{year}"
      filename_array << "#{day}_#{month}_#{year}"
    end
  end


# Build array of SIF values (just two?) 
# 3712 2543 4238 2500 1751 3047 3062 4334 3250
#sif_array = [1751, 2500]


# Loop through SIF values and legitimate dates. For each, build URL to "get"
# http://rastreabilidade.marfrig.com.br/rastreabilidade/origem-lotes.asp?sif=1751&data_producao=24%2F02%2F2012
url = "http://www.marfrig.com.br/rastreabilidade/origem-lotes.asp"

post_data = Hash.new
post_data[:sif] = "1497"
post_data[:data_producao] = "29/02/2012"

#uf_array = Array.new

#for sif in sif_array
#  for date in date_array
#    uf_array << {:url => "#{url_base}sif=#{sif}&data_producao=#{date}", :file => "#{sif}_#{date}.html"}
#  end
#end

# set up curl session
curl = CURL.new
curl.user_agent_alias = "Mac Safari"

cleanup_array = Array.new
cleanup_filename_array = Array.new

sif_array.each do |sif|
  date_array.each_with_index do |date,index|
    begin
      Timeout::timeout(30) do
        file = "#{sif}_#{filename_array[index]}.html"
        f = File.open("#{result_dir}#{sif}/#{file}", 'w')

        post_data[:sif] = sif
        post_data[:data_producao] = date

        result = curl.post(url, post_data) 

        f.write(result)
        f.close()
      end
    rescue => error
      raise unless error.instance_of? Timeout::Error
      cleanup_array << [sif,date] 
      cleanup_filename_array << "#{sif}_#{filename_array[index]}"
      next
    end
  end
end

unless cleanup_array.empty?
  cleanup_array.each_with_index do |arr, index|
    begin
      Timeout::timeout(30) do
        sif = cleanup_array[index][0]
        date = cleanup_array[index][1]
        file = "#{sif}_#{date}.html"
        f = File.open("#{result_dir}#{file}", 'w')
#        f = File.open("#{result_dir}#{sif}_#{date}.html", 'w')
        url = "#{url_base}sif=#{sif}&data_producao=#{date}"

        result = curl.get(url)

        f.write(result)
        f.close()
      end
    rescue => error
      raise unless error.instance_of? Timeout::Error
      next
    end
  end
end
