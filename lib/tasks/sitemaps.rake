require "csv"
require 'nokogiri'
require 'open-uri'
require 'mechanize'

namespace 'sitemaps' do

  
  desc "read veromi sitemaps"
  task "validate", [:url] => [:environment] do |t, args|
    url = args[:url]
    url = "http://www.weedsta.com/sitemaps/sitemap.xml" if url.nil?
    urls = Array.new()

    doc = Nokogiri::HTML(open(url,'User-Agent' => "weesta-sitemap-prewarm").read)
    
    doc.remove_namespaces! 
    
    doc.xpath('//url/loc').each_with_index do |link, index|
      urls.push(link.content)
      break if index > 10        
    end
    
    puts "TOTAL: #{urls.size}"
    
    a = Mechanize.new 
    a.user_agent = 'weesta-sitemap-prewarm'
    
           
    result_hash = Hash.new
    
    urls.each {|url|
      puts "Processing: #{url}"
      page = a.head(url)
      if !result_hash.has_key? page.code.to_i
        result_hash[page.code.to_i] = {"count" => 1, "lists" => Array.new}
      else
        result_hash[page.code.to_i]["count"] += 1
        if page.code.to_i != 200
          result_hash[page.code.to_i]["lists"].push url
        end              
      end

    }
    
    File.open('log.txt', 'w') do |f|
      puts "TOTAL: #{urls.size}"
      f.puts "TOTAL: #{urls.size}"
      result_hash.keys.sort.each do |key|
        puts "[#{key}]: #{result_hash[key]["count"]}"
        f.puts "[#{key}]: #{result_hash[key]["count"]}"
        if key != 200   
          result_hash[key]["lists"].each do |l|
            puts  l
            f.puts  l
          end     
        end
      end
    end            
  end 
  
  
end
#rake content:split["/Volumes/Time Machine Backups/others/tmp",party.tab,50000000,PfParty]
#rake content:split["/Volumes/Time Machine Backups/others/tmp",name.tab,50000000,PfName]