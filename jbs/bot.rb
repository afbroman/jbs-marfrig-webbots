#!/usr/bin/env ruby

require 'curl'
require 'uri'
require 'timeout'

if ARGV.empty?
  puts "Usage: <filename> <list of sifs>"
  exit
else
  sif_array = ARGV
end

result_dir = "/Users/abroman/Documents/SAGE Project/Results/JBS"

# Build array of legitimate dates (check email from Holly for limits)
#   * check email from Holly for limits (10/1/2008 to 2/29/2012)
#   * look at marfrig code for legitimate dates (marfrig_date_code.html)

# The use of integers & strings here is rather messy. TODO: Fix the use of strings/integer
date_array = Array.new
filename_array = Array.new

for year in 2008..2012
  for month in 1..12
    month = "0#{month}" if month < 10
    for day in 1..31
      day = "0#{day}" if day < 10

      # Limit 2008 to after October 1st
      next if year == 2008 && month.to_i < 10

      # Limit 2012 to before July 1st
      next if year == 2012 && month.to_i > 6
      
      # Limit April, June, September, and November 
      next if day == 31 && (month == "04" || month == "06" || month == "09" || month == 11)
      # Limit February
      next if (day == 29 || day == 30 || day == 31) && month == "02"
      
      date_array << "#{day}/#{month}/#{year}"
      filename_array << "#{day}_#{month}_#{year}"
      
    end
  end
end

date_array << "29/02/2012"
filename_array << "29_02_2012"


#sif_array = [4121,2979,42,2837,2601,826,3000,200]

# Loop through SIF values and legitimate dates. For each, build URL to "get"
# http://rastreabilidade.marfrig.com.br/rastreabilidade/origem-lotes.asp?sif=1751&data_producao=24%2F02%2F2012
url = "http://www.jbs.com.br/rastreabilidade-resultado.aspx"

post_data = Hash.new

post_data[:__VIEWSTATE] = "/wEPDwUKLTg2OTcwMDgxOQ9kFgJmD2QWAgIDD2QWAgIJD2QWBgIBD2QWAgIDDw8WAh4EVGV4dAUPUmFzdHJlYWJpbGlkYWRlZGQCAw8PFgIfAAUPUmFzdHJlYWJpbGlkYWRlZGQCBQ8WAh4LXyFJdGVtQ291bnQCARYCZg9kFgoCAQ8PFgIeB1Zpc2libGVoZGQCAw8PFgIfAAWPDjxwPkEgSkJTIGFwb2lhIG8gY3Jlc2NpbWVudG8gc3VzdGVudCYjMjI1O3ZlbCBkYSBwZWN1JiMyMjU7cmlhIGUsIHBvciBpc3NvLCBjcmlvdSB1bWEgcG9sJiMyMzc7dGljYSBpbnRlcm5hIGRlIGNvbXByYSBkZSAgICAgICAgIGdhZG8gcXVlIHRlbSBjb21vIG9iamV0aXZvIGdhcmFudGlyIGEgb3JpZ2VtIGRlIHN1YSBtYXQmIzIzMztyaWEtcHJpbWEsIGV2aXRhbmRvIHF1ZSBvcyBhbmltYWlzIGFkcXVpcmlkb3MgICAgICAgICBzZWphbSBwcm92ZW5pZW50ZXMgZGUgZm9ybmVjZWRvcmVzIHF1ZSBlc3QmIzIyNztvIG5hcyBsaXN0YXMgZG9zIHF1ZSBwcmF0aWNhbSBvIGRlc21hdGFtZW50bywgcmVhbGl6YW0gdHJhYmFsaG8gICAgICAgICBlc2NyYXZvLCBlc3QmIzIyNztvIGVtICYjMjI1O3JlYXMgaW5kJiMyMzc7Z2VuYXMgZSBlbSB1bmlkYWRlcyBkZSBjb25zZXJ2YSYjMjMxOyYjMjI3O28uPC9wPiAgICAgICAgDQo8cD5BIGNvbnN1bHRhIGEgZXN0YXMgbGlzdGFzICYjMjMzOyByZWFsaXphZGEgZW0gZG9pcyBtb21lbnRvcy4gTm8gYXRvIGRhIGNvbXByYSBlIG5vIG1vbWVudG8gZW0gcXVlIG9zIGFuaW1haXMgICAgICAgICBzZWd1ZW0gcGFyYSBvIGFiYXRlLCBjb20gYSBmaW5hbGlkYWRlIGRlIGdhcmFudGlyIHF1ZSBhIGNhZGVpYSBkZSBjYXJuZSBib3ZpbmEgc2VqYSBzdXN0ZW50JiMyMjU7dmVsIGUgb2ZlcmUmIzIzMTthICAgICAgICAgYW9zIHNldXMgY2xpZW50ZXMgdW0gcHJvZHV0byBkZSBxdWFsaWRhZGUsIGNvbSBwcm9jZWQmIzIzNDtuY2lhIGdhcmFudGlkYSBlIHF1ZSByZXNwZWl0ZSBhcyBib2FzIHByJiMyMjU7dGljYXMgZGUgcHJvZHUmIzIzMTsmIzIyNztvLjwvcD4gICAgICAgIA0KPHA+UGFyYSBnYXJhbnRpciBhIHRyYW5zcGFyJiMyMzQ7bmNpYSBkYSBvcmlnZW0gZG9zIHByb2R1dG9zLCBhIEpCUyBjcmlvdSBvIHNpc3RlbWEgZGUgY29uc3VsdGEgYSByYXN0cmVhYmlsaWRhZGUuICAgICAgICAgUG9yIG1laW8gZGVzdGUgc2lzdGVtYSwgbyBjb25zdW1pZG9yIHRlciYjMjI1OyBhY2Vzc28gJiMyMjQ7IGxpc3RhIGRlIHByb3ByaWVkYWRlcyBkZSBvcmlnZW0gZG9zIGFuaW1haXMgcXVlIGdlcmFyYW0gbyAgICAgICAgIHByb2R1dG8gZmluYWwuPC9wPiAgICAgICAgDQo8cD5Db20gaXNzbywgdG9kb3Mgc2FiZXImIzIyNztvIGEgb3JpZ2VtIGRhIGNhcm5lIHF1ZSBlc3QmIzIyNTsgc2VuZG8gYWRxdWlyaWRhIGUgdGVyJiMyMjc7byBhIGNlcnRlemEgZGUgcXVlIG4mIzIyNztvIGVzdCYjMjI3O28gY29tcHJhbmRvICAgICAgICAgcHJvZHV0b3MgZGUgJiMyMjU7cmVhcyBlbWJhcmdhZGFzIG91IGNvbSBwciYjMjI1O3RpY2FzIGRlIHRyYWJhbGhvIGVzY3Jhdm8uIEVzdGEgZm9pIGEgZm9ybWEgZW5jb250cmFkYSBwYXJhIGNvbXBhcnRpbGhhciAgICAgICAgIGNvbSBub3Nzb3MgY2xpZW50ZXMgZSB0YW1iJiMyMzM7bSBjb20gb3MgY2lkYWQmIzIyNztvcyBvIGNvbXByb21pc3NvIGRhIG5vc3NhIGVtcHJlc2EgY29tIGEgcmVzcG9uc2FiaWxpZGFkZSBzb2NpYWwgZSAgICAgICAgIGFtYmllbnRhbC48L3A+ICAgICAgICANCjxwPjxzdHJvbmc+UGFyYSB0ZXIgYWNlc3NvIGEgZXN0ZSBzaXN0ZW1hLCBiYXN0YSBxdWUgbyBjb25zdW1pZG9yIGluc2lyYSBvIG4mIzI1MDttZXJvIGRvIFNlcnZpJiMyMzE7byBkZSBJbnNwZSYjMjMxOyYjMjI3O28gRmVkZXJhbCAoU0lGKSwgICAgICAgICBzZWd1aWRvIGRhIGRhdGEgZGUgcHJvZHUmIzIzMTsmIzIyNztvIG5vIGZvcm11bCYjMjI1O3JpbyBkZSByYXN0cmVhYmlsaWRhZGUgYWJhaXhvOjwvc3Ryb25nPjwvcD5kZAIFDxYCHwFmZAIHDxYCHwECAWQCCQ8WAh8BZmQYAwUeX19Db250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgEFFmN0bDAwJFRvcG8kSW1hZ2VCdXR0b24FF2N0bDAwJFJvZGFwZSRNdWx0aVZpZXcxDw9kZmQFD2N0bDAwJG12Q29uaGVjYQ8PZAIBZBNdq8rBCW/XGKYQe/pfs7k+leo7"

post_data[:__PREVIOUSPAGE] = "IraGZbAUKRhmXzHl28u_lyNMO0zoh23A1TgghqB5DZ8EuGWOK2REOoxgvJpc9x4w95mfolArnSgrFOzKRAwa7EotdUma2fX3Tj2Jk8Y8uElskSAp0"

post_data[:__EVENTVALIDATION] = "/wEWFAKHy5q6BQKovez4CgLo9JihBgLRhamfDgLFno6GDgKRmbH7BAKFrsPUDALQ0tr+CgLc+O3uAgLKg8/4BwL+rpDMDQKs+9CnDgLfmY6QBwKNj8q9BwKO3oDRCAKK08HUAwLggKemBwKGrNPgCAKcl/D4BAKJlbGlCQLNT7pIPtfmsAxSNZCqpYbSt6jc"

post_data["ctl00%24Topo%24slcMundo"] = "Default.aspx" 
post_data["ctl00%24Topo%24slcSite"] = "Default.aspx" 
post_data["ctl00%24Topo%24TextBox"] = "Busca" 
post_data["ctl00%24ContentPlaceHolder1%24txtsif"] = "4121" 
post_data["ctl00%24ContentPlaceHolder1%24txtdata_producao"] = "19/05/2010" 
post_data["ctl00%24ContentPlaceHolder1%24btpesquisar"] = "Pesquisar"




# set up curl session
curl = CURL.new({:connect_timeout => 25, :retry => 20})
curl.user_agent_alias = "Mac Safari"

cleanup_array = Array.new
cleanup_filename_array = Array.new

sif_array.each do |sif|
  date_array.each_with_index do |date,index|

    begin
      Timeout::timeout(30) do
        f = File.open("#{result_dir}#{sif}_#{filename_array[index]}.html", 'w')
        post_data["ctl00%24ContentPlaceHolder1%24txtsif"] = sif
        post_data["ctl00%24ContentPlaceHolder1%24txtdata_producao"] = date 

        result = curl.post(url, post_data) 

        #sleep(1)

        f.write(result)
        f.close() 
      end
    rescue => error
      raise unless error.instance_of? Timeout::Error
      cleanup_array << [sif, date]
      cleanup_filename_array << "#{sif}_#{filename_array[index]}"
      next
    end
  end
end

unless cleanup_array.empty?
  cleanup_array.each_with_index do |arr, index|
    begin
      Timeout::timeout(30) do
        f = File.open("#{result_dir}#{cleanup_filename_array[index]}.html", 'w')
        post_data["ctl00%24ContentPlaceHolder1%24txtsif"] = arr[0] 
        post_data["ctl00%24ContentPlaceHolder1%24txtdata_producao"] = arr[1]

        result = curl.post(url, post_data)

        #sleep(1)
        f.write(result)
        f.close()
      end
    rescue => error
      raise unless error.instance_of? Timeout::Error
      next
    end
  end
end
