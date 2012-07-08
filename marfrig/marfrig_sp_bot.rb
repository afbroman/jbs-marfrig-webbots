#!/usr/bin/env ruby

require 'curl'

result_dir = "/Volumes/Backup/SAGE Results/"

# Build array of legitimate dates (check email from Holly for limits)
#   * check email from Holly for limits (10/1/2008 to 2/29/2012)
#   * look at marfrig code for legitimate dates (marfrig_date_code.html)

# The use of integers & strings here is rather messy. TODO: Fix the use of strings/integer
date_array = Array.new

date_array << "29%2F04%2F2011"

# Build array of SIF values (just two?) 
# 3712 2543 4238 2500 1751 3047 3062 4334 3250
sif_array = [4334]


# Loop through SIF values and legitimate dates. For each, build URL to "get"
# http://rastreabilidade.marfrig.com.br/rastreabilidade/origem-lotes.asp?sif=1751&data_producao=24%2F02%2F2012
url_base = "http://rastreabilidade.marfrig.com.br/rastreabilidade/origem-lotes.asp?"

uf_array = Array.new

for sif in sif_array
  for date in date_array
    uf_array << {:url => "#{url_base}sif=#{sif}&data_producao=#{date}", :file => "#{sif}_#{date}.html"}
  end
end

# set up curl session
curl = CURL.new
curl.user_agent_alias = "Google"

for uf in uf_array
  f = open("#{result_dir}#{uf[:file]}", 'w')
  result = curl.get(uf[:url]) 
  
  f.write(result)
  f.close()
end
