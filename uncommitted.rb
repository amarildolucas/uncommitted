#!/usr/bin/env ruby 
require 'net/https'
require 'uri'
require 'json'

# Check if git was initialized in the current directory/folder
# Run "git status" and write the expected result to a created file.txt 
# Iterate the lines of the file searching for keywords/sentences. 
  # Current branch name 
  # Messages (Changes not staged for commit, Untracked files, etc...)
  # Actions (deleted: file, modified: file, etc...)
  # File name with extension (file.rb, file.txt)
# Return notifications with defined states (branch name, messages, actions and file name)
# Show in the console 
# Post to configured slack channel (uncommittedbot)
# Distribute manually on github 

SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
UNCOMMITTED_FILE = "uncommitted.txt"
GIT_STATUS_COMMAND = "git status"

def show_notification(message)
  puts "#{message}"
end  

def post_to_slack(webhook_url, json_data)
    uri = URI(webhook_url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, 'Content-Type': 'application/json')
    request.body = json_data
    response = https.request(request)
    show_notification("Posted to slack.")
rescue => exception
    puts "Failed with: #{exception}"
end

# Run 'git status' in command line and redirect to created uncommitted.txt file  
`#{GIT_STATUS_COMMAND} > uncommitted.txt`

File.open(UNCOMMITTED_FILE, 'r') do |file|
  line_number = 0
  file.readlines.each do |line|
    keywords_in_line = line.chomp.split
    if keywords_in_line.include?('modified:')  
      message = "Uncommitted changes in line #{line_number} with 'modified' in #{File.basename(UNCOMMITTED_FILE)}"
      post_to_slack(SLACK_WEBHOOK_URL, {text: message}.to_json)
    elsif keywords_in_line.include?('deleted:')
      message = "Uncommitted changes in line #{line_number} with 'deleted' in #{File.basename(UNCOMMITTED_FILE)}"
      post_to_slack(SLACK_WEBHOOK_URL, {text: message}.to_json)
    end  
    line_number += 1 
  end 
end 