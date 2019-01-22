require 'nokogiri'
require 'open-uri'
require 'pry'

class Scrapper

    def initialize

    end

    def get_val_doise_urls
        doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
    
        names = []
    
        doc.xpath('//tr[2]//p//a/@href').each do |node|
            names.push(node.text)
        end
        result_url = names.map do |x|
            x[1..-1]
        end
        return result_url
    end
    
    def get_mayors_names
        doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
    
        names_of_town = []
        
        doc.xpath('//tr[2]//p/a').each do |node|
            names_of_town.push(node.text)
        end
        return names_of_town
    end
    
    def get_mayers_emails
        n = get_townhall_urls.count
        i = 0
        emails = []
        while i < n
            doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com#{get_townhall_urls[i].to_s}"))
            result = doc.xpath('//section[2]/div/table/tbody/tr[4]/td[2]').map do |node|
                emails.push(node.text)
            end
            p emails[i]
            i += 1
        end
    
        names = get_townhall_names
        result_scrap = names.map.with_index do |name, index|
            new_hash = {}
            new_hash[name] = emails[index]
            new_hash
        end
    
        return result_scrap
    end

end

