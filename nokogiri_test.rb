#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

page = Nokogiri::HTML(open("http://www.linkedin.com/company/1412"))

# Product Lab: http://www.linkedin.com/company/3006652 - no specialties
# NG: http://www.linkedin.com/company/1412 - everything
# NFWF: http://www.linkedin.com/company/32791 - no description or specialites

# Get the description and specialties, if they exist, otherwise, make them N/A
if page.css("div.text-logo")
  page.css("div.text-logo p")[0] ? description = page.css("div.text-logo p")[0].text.strip.gsub("\n", " ") : description = "N/A"
  page.css("div.text-logo p")[1] ? specialties = page.css("div.text-logo p")[1].text.strip.gsub("\n", "") : specialties = "N/A"
end

puts "Description: " + description
puts "Specialities: " + specialties

# Get the Type, Company Size, Website, Industry, Year Founded - if they exist
clean_li_data = {}

i = 0
while i < page.xpath("//dl/dt").length
  clean_li_data.merge! page.xpath("//dl/dt")[i].text.strip => page.xpath("//dl/dd")[i].text.strip
  i += 1
end

# Create the variables for insertion
clean_li_data.has_key?("Company Size") ? company_size = clean_li_data['Company Size'] : company_size = "N/A"
clean_li_data.has_key?("Website") ? website_url = clean_li_data['Website'] : website_url = "N/A"
clean_li_data.has_key?("Industry") ? industry = clean_li_data['Industry'] : industry = "N/A"
clean_li_data.has_key?("Type") ? company_type = clean_li_data['Type'] : company_type = "N/A"
clean_li_data.has_key?("Founded") ? founded = clean_li_data['Founded'] : founded = "N/A"

puts "Here's more info:"
puts "Company Size: " + company_size
puts "Company Type: " + company_type
puts "Industry: " + industry
puts "Website: " + website_url
puts "Founded: " + founded