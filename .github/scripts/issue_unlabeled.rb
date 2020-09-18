# issue_labeled.rb
# Runs when an issue is labeled.

require "slop"
require "octokit"

MAGIC_LABEL_NAME = "test"
GITHUB_PROJECT_TODO_COLUMN_ID = 10860613
GITHUB_PROJECT_BOARD_URL = "https://github.com/d12/GitHub-Actions-Testing/projects/1"
GITHUB_REPO_NWO = "d12/GitHub-Actions-Testing"

def args
  @args ||= Slop.parse do |o|
    o.string "--label_name", "The name of the label we're being notified about"
    o.string "--issue_number", "The number of the issue"
    o.string "--github_token", "The GitHub token"
  end
end

def github_client
  @github_client ||= begin
    client = Octokit::Client.new(access_token: args[:github_token])
    client.auto_paginate = true

    client
  end
end

# Is this webhook event firing for the magic label?
def event_for_magic_label?
  args[:label_name] == MAGIC_LABEL_NAME
end

def find_card_id
  comments = github_client.issue_comments(GITHUB_REPO_NWO, args[:issue_number])
  return unless comments

  matching_comment = comments.find_all { |c| /Card ID: \d+/ =~ c.body }.last
  return unless matching_comment

  /Card ID: (\d+)/.match(matching_comment.body).captures.first
end

def remove_card_from_board!(card_id)
  github_client.delete_project_card(card_id)
end

def add_comment_to_issue!
  github_client.add_comment(GITHUB_REPO_NWO,
    args[:issue_number],
    "Beep boop. I saw you removed the #{MAGIC_LABEL_NAME} label, \
     I've removed this issue from [the shared project board](#{GITHUB_PROJECT_BOARD_URL})."
  )
end

# Script begin

puts "Arguments: #{args.to_h}"

unless event_for_magic_label?
  puts "Label is not interesting. Bailing!"
  exit 0
end

puts "Removing note from project board..."

card_id = find_card_id
puts card_id

result = remove_card_from_board!(card_id)

unless result
  puts "Could not remove card from board"
end

puts "Adding comment to issue..."

add_comment_to_issue!

puts "Done!"
