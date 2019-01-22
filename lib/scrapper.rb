Dotenv.load('../.env')
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'json'
require 'pp'
require 'google_drive'
require 'csv'
require 'dotenv'
require 'tty-prompt'



class Scrapper

    attr_accessor :name, :time

#Fetch names and numbers of different scrap 
    @@scrap_names = []
    @@scrap_numbers = 0

#Initialize de app with a name, and the time of the scrap is saved
    def initialize
        prompt = TTY::Prompt.new
        result = prompt.ask("What name do you want to give to your scrap?")
        @name = result
        @time = Time.now
        puts "Your scrap is : #{@name}"
        array = [@name, @time]
        @@scrap_numbers = @@scrap_numbers + 1
        @@scrap_names << array
    end

#Fetch website's URLS 
    def get_townhall_urls
        doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))

        names = []
    
        doc.xpath('//tr[2]//p//a/@href').each do |node|
            names.push(node.text)
        end
        @result_url = names.map do |x|
            x[1..-1]
        end
        return @result_url
    end

#Fetch Mayor's names
    def get_townhall_names
        doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
    
        @names_of_town = []
        
        doc.xpath('//tr[2]//p/a').each do |node|
            @names_of_town.push(node.text)
        end
        return @names_of_town
    end

#Fetch, via get_townhall_urls, the mayor's emails
    def get_townhall_emails
    n = get_townhall_urls.count
    i = 0
    @emails = []
        while i <= 4
            doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com#{get_townhall_urls[i].to_s}"))
            result = doc.xpath('//section[2]/div/table/tbody/tr[4]/td[2]').map do |node|
                @emails.push(node.text)
            end
            p @emails[i]
            i += 1
        end
        @result_scrap = Hash[@names_of_town.zip(@emails)]
        return @result_scrap
    end

#Allow you to see how many scraps has been done via Scrapper's object
    def self.all 
        puts @@scrap_names.inspect
        return @@scrap_names.inspect
    end

#Allow you to count the number of scraps
    def self.count
        return @@scrap_numbers
    end
    
#Allow you to count the numbers of mails scrapped
    def count 
        puts "Tu as scrappé #{@result_scrap.count} élémént(s)"
        return @result_scrap.count
    end

#Function that sends datas to google Spreadsheet
#The link is protected by ENV
#Send me an email if you want to test it
    def save_as_spreadsheet
        session = GoogleDrive::Session.from_config("../config.json")
        ws = session.spreadsheet_by_key(ENV['SPREADSHEET_KEY']).worksheets[0]
        ws.reload
        i = 0
        n = get_townhall_urls.count
        while i <= 4
            ws[i+1, 1] = @emails[i]
            ws[i+1, 2] = @names_of_town[i]
        i +=1
        end
        ws.save
    end

#Method that can save datas into json
    def save_as_JSON
        @result_pretty = JSON.pretty_generate(@result_scrap)
        File.open("./db/#{@name}.json","w") do |f|
            f.write(@result_pretty)
        end
    end

#Method that can save datas into csv
    def save_as_csv
        CSV.open("./db/#{@name}.csv", "wb") {|csv| @result_scrap.to_a.each {|elem| csv << elem} }
    end

#Wrap it up boys, launch the program in app.rb with Scrapper.new("name_of_scrap").perform
    def perform
        get_townhall_urls
        get_townhall_names
        get_townhall_emails

#Prompt just promt a choice for the user
        prompt = TTY::Prompt.new
        result = prompt.select("Do you want to downlad as...", %w(CSV JSON Spreadsheet))
        if result == "CSV"
            puts "You've choosen CSV, your file is in scrapper_v2/db as #{@name}.csv"
            save_as_csv
        elsif result == "JSON"
            puts "You've choosen JSON, your file is in scrapper_v2/db as #{@name}.json"
            save_as_JSON
        else
            puts "Sorry, Using speadsheet require a key..."
            exit
        end
    end
end