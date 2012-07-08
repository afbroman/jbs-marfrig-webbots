#!/usr/bin/env ruby

def get_fazendas()
  
end

def get_incr()
  
end

def get_mun()

end

result = Array.new
doc.css('table tr td').each { |i| result << i.content.rstrip }
result.each_slice(5).map {|i| p (i[0])}
