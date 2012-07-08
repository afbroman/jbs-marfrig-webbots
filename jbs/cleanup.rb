#!/usr/bin/env ruby

require 'curl'
require 'uri'
require 'timeout'

result_dir = "/Volumes/Backup/SAGE Results/JBS/"

# Build array of legitimate dates (check email from Holly for limits)
#   * check email from Holly for limits (10/1/2008 to 2/29/2012)
#   * look at marfrig code for legitimate dates (marfrig_date_code.html)

# The use of integers & strings here is rather messy. TODO: Fix the use of strings/integer
filename_array = ["01_04_2012"]
date_array = ["01/04/2012"]

#sif_array = [4121,2979,42,2837,2601,826,3000,200]
sif_array = [457]

# Loop through SIF values and legitimate dates. For each, build URL to "get"
# http://rastreabilidade.marfrig.com.br/rastreabilidade/origem-lotes.asp?sif=1751&data_producao=24%2F02%2F2012
url = "http://www.jbs.com.br/rastreabilidade-resultado.aspx"

post_data = Hash.new

post_data[:__VIEWSTATE] = "/wEPDwUKLTg2OTcwMDgxOQ9kFgJmD2QWAgIDD2QWAgIJD2QWBgIBD2QWAgIDDw8WAh4EVGV4dAUPUmFzdHJlYWJpbGlkYWRlZGQCAw8PFgIfAAUPUmFzdHJlYWJpbGlkYWRlZGQCBQ8WAh4LXyFJdGVtQ291bnQCARYCZg9kFgoCAQ8PFgIeB1Zpc2libGVoZGQCAw8PFgIfAAWPDjxwPkEgSkJTIGFwb2lhIG8gY3Jlc2NpbWVudG8gc3VzdGVudCYjMjI1O3ZlbCBkYSBwZWN1JiMyMjU7cmlhIGUsIHBvciBpc3NvLCBjcmlvdSB1bWEgcG9sJiMyMzc7dGljYSBpbnRlcm5hIGRlIGNvbXByYSBkZSAgICAgICAgIGdhZG8gcXVlIHRlbSBjb21vIG9iamV0aXZvIGdhcmFudGlyIGEgb3JpZ2VtIGRlIHN1YSBtYXQmIzIzMztyaWEtcHJpbWEsIGV2aXRhbmRvIHF1ZSBvcyBhbmltYWlzIGFkcXVpcmlkb3MgICAgICAgICBzZWphbSBwcm92ZW5pZW50ZXMgZGUgZm9ybmVjZWRvcmVzIHF1ZSBlc3QmIzIyNztvIG5hcyBsaXN0YXMgZG9zIHF1ZSBwcmF0aWNhbSBvIGRlc21hdGFtZW50bywgcmVhbGl6YW0gdHJhYmFsaG8gICAgICAgICBlc2NyYXZvLCBlc3QmIzIyNztvIGVtICYjMjI1O3JlYXMgaW5kJiMyMzc7Z2VuYXMgZSBlbSB1bmlkYWRlcyBkZSBjb25zZXJ2YSYjMjMxOyYjMjI3O28uPC9wPiAgICAgICAgDQo8cD5BIGNvbnN1bHRhIGEgZXN0YXMgbGlzdGFzICYjMjMzOyByZWFsaXphZGEgZW0gZG9pcyBtb21lbnRvcy4gTm8gYXRvIGRhIGNvbXByYSBlIG5vIG1vbWVudG8gZW0gcXVlIG9zIGFuaW1haXMgICAgICAgICBzZWd1ZW0gcGFyYSBvIGFiYXRlLCBjb20gYSBmaW5hbGlkYWRlIGRlIGdhcmFudGlyIHF1ZSBhIGNhZGVpYSBkZSBjYXJuZSBib3ZpbmEgc2VqYSBzdXN0ZW50JiMyMjU7dmVsIGUgb2ZlcmUmIzIzMTthICAgICAgICAgYW9zIHNldXMgY2xpZW50ZXMgdW0gcHJvZHV0byBkZSBxdWFsaWRhZGUsIGNvbSBwcm9jZWQmIzIzNDtuY2lhIGdhcmFudGlkYSBlIHF1ZSByZXNwZWl0ZSBhcyBib2FzIHByJiMyMjU7dGljYXMgZGUgcHJvZHUmIzIzMTsmIzIyNztvLjwvcD4gICAgICAgIA0KPHA+UGFyYSBnYXJhbnRpciBhIHRyYW5zcGFyJiMyMzQ7bmNpYSBkYSBvcmlnZW0gZG9zIHByb2R1dG9zLCBhIEpCUyBjcmlvdSBvIHNpc3RlbWEgZGUgY29uc3VsdGEgYSByYXN0cmVhYmlsaWRhZGUuICAgICAgICAgUG9yIG1laW8gZGVzdGUgc2lzdGVtYSwgbyBjb25zdW1pZG9yIHRlciYjMjI1OyBhY2Vzc28gJiMyMjQ7IGxpc3RhIGRlIHByb3ByaWVkYWRlcyBkZSBvcmlnZW0gZG9zIGFuaW1haXMgcXVlIGdlcmFyYW0gbyAgICAgICAgIHByb2R1dG8gZmluYWwuPC9wPiAgICAgICAgDQo8cD5Db20gaXNzbywgdG9kb3Mgc2FiZXImIzIyNztvIGEgb3JpZ2VtIGRhIGNhcm5lIHF1ZSBlc3QmIzIyNTsgc2VuZG8gYWRxdWlyaWRhIGUgdGVyJiMyMjc7byBhIGNlcnRlemEgZGUgcXVlIG4mIzIyNztvIGVzdCYjMjI3O28gY29tcHJhbmRvICAgICAgICAgcHJvZHV0b3MgZGUgJiMyMjU7cmVhcyBlbWJhcmdhZGFzIG91IGNvbSBwciYjMjI1O3RpY2FzIGRlIHRyYWJhbGhvIGVzY3Jhdm8uIEVzdGEgZm9pIGEgZm9ybWEgZW5jb250cmFkYSBwYXJhIGNvbXBhcnRpbGhhciAgICAgICAgIGNvbSBub3Nzb3MgY2xpZW50ZXMgZSB0YW1iJiMyMzM7bSBjb20gb3MgY2lkYWQmIzIyNztvcyBvIGNvbXByb21pc3NvIGRhIG5vc3NhIGVtcHJlc2EgY29tIGEgcmVzcG9uc2FiaWxpZGFkZSBzb2NpYWwgZSAgICAgICAgIGFtYmllbnRhbC48L3A+ICAgICAgICANCjxwPjxzdHJvbmc+UGFyYSB0ZXIgYWNlc3NvIGEgZXN0ZSBzaXN0ZW1hLCBiYXN0YSBxdWUgbyBjb25zdW1pZG9yIGluc2lyYSBvIG4mIzI1MDttZXJvIGRvIFNlcnZpJiMyMzE7byBkZSBJbnNwZSYjMjMxOyYjMjI3O28gRmVkZXJhbCAoU0lGKSwgICAgICAgICBzZWd1aWRvIGRhIGRhdGEgZGUgcHJvZHUmIzIzMTsmIzIyNztvIG5vIGZvcm11bCYjMjI1O3JpbyBkZSByYXN0cmVhYmlsaWRhZGUgYWJhaXhvOjwvc3Ryb25nPjwvcD5kZAIFDxYCHwFmZAIHDxYCHwECAWQCCQ8WAh8BZmQYAwUeX19Db250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgEFFmN0bDAwJFRvcG8kSW1hZ2VCdXR0b24FF2N0bDAwJFJvZGFwZSRNdWx0aVZpZXcxDw9kZmQFD2N0bDAwJG12Q29uaGVjYQ8PZAIBZOO2HBO9pT9m4eRCSRW/tU9CIbKe"

post_data[:__PREVIOUSPAGE] = "PUVs53DgLmle4hyZmVi7o0q3dzmCEXcIWpfFveeRM-3Do_N1Ee4Qi295vsxeTQmdylCjvtbDIxjUaob5hT_y6sxmuGVXkB8ftvFyWywOm1giRLGb0"

post_data[:__EVENTVALIDATION] = "/wEWFALq8+cVAqi97PgKAuj0mKEGAtGFqZ8OAsWejoYOApGZsfsEAoWuw9QMAtDS2v4KAtz47e4CAsqDz/gHAv6ukMwNAqz70KcOAt+ZjpAHAo2Pyr0HAo7egNEIAorTwdQDAuCAp6YHAoas0+AIApyX8PgEAomVsaUJi/BU7Cx+am9ZA0l9QXABXMae+lQ="

post_data["ctl00%24Topo%24slcMundo"] = "Default.aspx" 
post_data["ctl00%24Topo%24slcSite"] = "Default.aspx" 
post_data["ctl00%24Topo%24TextBox"] = "Busca" 
post_data["ctl00%24ContentPlaceHolder1%24txtsif"] = "" 
post_data["ctl00%24ContentPlaceHolder1%24txtdata_producao"] = ""
post_data["ctl00%24ContentPlaceHolder1%24btpesquisar"] = "Pesquisar"

# set up curl session
curl = CURL.new({:connect_timeout => 25, :retry => 20})
curl.user_agent_alias = "Mac Safari"

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
      next
    end
  end
end
