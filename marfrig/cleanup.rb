#!/usr/bin/env ruby

require 'curl'
require 'uri'
require 'timeout'

result_dir = "/Volumes/Backup/SAGE Results/marfrig/"

#if ARGV.empty?
#  puts "Usage: <filename> <list of sifs>"
#  exit
#else
#  sif_array = ARGV
#end

# Build array of legitimate dates (check email from Holly for limits)
#   * check email from Holly for limits (10/1/2008 to 2/29/2012)
#   * look at marfrig code for legitimate dates (marfrig_date_code.html)

# The use of integers & strings here is rather messy. TODO: Fix the use of strings/integer
date_array = ["29%2F12%2F2010", "29%2F05%2F2010", "29%2F01%2F2011", "27%2F11%2F2009", "23%2F10%2F2009", "22%2F05%2F2011", "22%2F04%2F2011", "21%2F07%2F2010", "21%2F05%2F2010", "19%2F04%2F2011", "18%2F02%2F2011", "16%2F06%2F2011", "16%2F02%2F2011", "16%2F01%2F2011", "15%2F10%2F2010", "12%2F10%2F2008", "12%2F06%2F2011", "12%2F04%2F2011", "11%2F01%2F2011", "10%2F05%2F2011", "10%2F03%2F2011", "09%2F10%2F2011", "07%2F04%2F2011", "07%2F01%2F2012", "06%2F05%2F2011", "04%2F06%2F2011", "04%2F04%2F2011", "01%2F02%2F2011"]
sif_array = [2500]

# Build array of SIF values (just two?) 
# 3712 2543 4238 2500 1751 3047 3062 4334 3250
#sif_array = [1751, 2500]


# Loop through SIF values and legitimate dates. For each, build URL to "get"
# http://rastreabilidade.marfrig.com.br/rastreabilidade/origem-lotes.asp?sif=1751&data_producao=24%2F02%2F2012
url_base = "http://rastreabilidade.marfrig.com.br/rastreabilidade/origem-lotes.asp?"

#uf_array = Array.new

#for sif in sif_array
#  for date in date_array
#    uf_array << {:url => "#{url_base}sif=#{sif}&data_producao=#{date}", :file => "#{sif}_#{date}.html"}
#  end
#end

# set up curl session
curl = CURL.new
curl.user_agent_alias = "Mac Safari"

cleanup_filename_array = Array.new

for sif in sif_array
  for date in date_array
    begin
      Timeout::timeout(30) do
        url = "#{url_base}sif=#{sif}&data_producao=#{date}"
        file = "#{sif}_#{date}.html"
        f = open("#{result_dir}#{file}", 'w')
        result = curl.get(url) 

        f.write(result)
        f.close()
      end
    rescue => error
      raise unless error.instance_of? Timeout::Error
      cleanup_filename_array << "#{sif}_#{date}.html"
      next
    end
  end
end

unless cleanup_filename_array.empty?
  cleanup_filename_array.each_with_index do |arr, index|
    begin
      Timeout::timeout(30) do
        f = File.open("#{result_dir}#{cleanup_filename_array[index]}", 'w')

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
