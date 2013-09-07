#!/usr/bin/env ruby

# Connect to a local MongoDB Replication Set
# Grab the public LinkedIn profile given
# Save the data in the MongoDB database and collection provided in the config file

require 'parseconfig'
require 'linkedin-scraper'
require 'mongo'

include Mongo

# Parse the config file
config = ParseConfig.new('./li_data_gather_person_config.conf')

# Take the LI profile URL as our argument
li_profile_url = ARGV[0]

# Get the LI profile
profile = Linkedin::Profile.get_profile(li_profile_url)

# Get the values from the config file
# db_to_use = config['db_to_use']
# collection_to_use = config['collection_to_use']

# Open a connection to Mongo
# client = MongoClient.new(config['db_host'], config['db_port'])
client = Mongo::MongoReplicaSetClient.new(['localhost:27017'])
db     = client[config['db_to_use']]
coll   = db[config['collection_to_use']]

begin
  coll.insert( {
    "first_name" => profile.first_name,
    "last_name" => profile.last_name,
    "full_name" => profile.name,
    "title" => profile.title,
    "location" => profile.location,
    "country" => profile.country,
    "industry" => profile.industry,
    "picture_url" => profile.picture,
    "skills" => profile.skills,
    "organizations" => profile.organizations,
    "education" => profile.education,
    "current_companies" => profile.current_companies,
    "past_companies" => profile.past_companies,
    "websites" => profile.websites,
    "groups" => profile.groups,
    "education" => profile.education,
    "skills" => profile.skills,
    "recommended_visitors" => profile.recommended_visitors
  })

  puts "Record added to Mongo!"
rescue Exception => e
  
end