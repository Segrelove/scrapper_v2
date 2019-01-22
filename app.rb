require 'bundler'
Bundler.require

$:.unshift File.expand_path("./../lib", __FILE__)
require 'scrapper'

Scrapper.new("new_Scrap").perform

#Lancer ruby app.rb dans le root directory enregistrera un scrap en CSV + JSON + sur un spreadsheet !
#https://docs.google.com/spreadsheets/d/1PWggsoZcsvUURoXeQZbnhIjlLfsmU6SDiPf0J7RUW9k/edit?usp=sharing
