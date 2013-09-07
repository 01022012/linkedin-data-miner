#!/usr/bin/env ruby

# This script wholesale adds linkedin company information to a client record in mongo

require 'open-uri'
require 'nokogiri'
require 'mongo'

include Mongo


db_to_use = ARGV[0]                   # The Mongo database to connect to
collection_to_use = ARGV[1]           # The collection to use
linkedin_url_field = ARGV[2]          # The LinkedIn URL field in your Mongo database

# Connect to the database
client = MongoClient.new('localhost', 27017)
db = client[db_to_use]
collection = db[collection_to_use]

# Loop through the entire collection
# For every company with a LinkedIn company page url, go to the linkedin company page and retrieve them

collection.find.each do |record |
  if record[linkedin_url_field] && record[linkedin_url_field] != "N/A"

    # Open the LinkedIn company page with nokogiri
    page = Nokogiri::HTML(open(record[linkedin_url_field]))

    ##############################
    # Description and Specialities
    ##############################

    # Get the description and specialty data, if any exists on the page

    if page.css("div.text-logo")
      page.css("div.text-logo p")[0] ? description = page.css("div.text-logo p")[0].text.strip : description = "N/A"
      page.css("div.text-logo p")[1] ? specialties = page.css("div.text-logo p")[1].text.strip.gsub("\n", "") : specialties = "N/A"
    end

    #################
    # Additional Data
    #################

    # Potential fields include: Type, Company Size, Website, Industry, Year Founded
    # Create a hash from the additional data
    # This is dynamic so we'll get as many fields as we can

    clean_li_data = {}

    i = 0
    while i < page.xpath("//dl/dt").length
      clean_li_data.merge! page.xpath("//dl/dt")[i].text.strip => page.xpath("//dl/dd")[i].text.strip
      i += 1
    end

    # Create the variables for insertion. Set to "N/A" if there is no data
    clean_li_data.has_key?("Website") ? website_url = clean_li_data['Website'] : website_url = "N/A"
    clean_li_data.has_key?("Industry") ? industry = clean_li_data['Industry'] : industry = "N/A"
    clean_li_data.has_key?("Type") ? company_type = clean_li_data['Type'] : company_type = "N/A"
    clean_li_data.has_key?("Company Size") ? company_size = clean_li_data['Company Size'] : company_size = "N/A"
    clean_li_data.has_key?("Founded") ? founded = clean_li_data['Founded'] : founded = "N/A"

    #####################
    # Address Information
    #####################

    # Create the address variables for insertion. Set to "N/A" if there is no data
    page.css("span.street-address") ? address = page.css("span.street-address").text : address = "N/A"
    page.css("span.locality") ? city = page.css("span.locality").text : city = "N/A"
    page.css("span.region") ? state = page.css("span.region").text : state = "N/A"
    page.css("span.postal-code") ? zipcode = page.css("span.postal-code").text : zipcode = "N/A"
    page.css("span.country-name") ? country = page.css("span.country-name").text : country = "N/A"

    # Update the record in MongoDB with the LinkedIn data found
    begin
      puts "Updating a record in MongoDB"
      # clean_li_data.each do |key, value|
      #   collection.update({linkedin_url_field => record[linkedin_url_field]}, "$set" => { key => value })
      # end
      
    rescue Exception => e
      
    end

    # Sleep the script for some random amount of time so we don't piss off LinkedIn
    sleep(rand(12..27))
  end
end