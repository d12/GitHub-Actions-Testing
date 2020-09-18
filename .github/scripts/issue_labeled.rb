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
    o.string "--issue_title", "The title of the issue"
    o.string "--issue_url", "The URL of the issue"
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

def add_card_to_board!
  github_client.create_project_card(GITHUB_PROJECT_TODO_COLUMN_ID,
    note: "(**From Borg**) [#{args[:issue_title]}](#{args[:issue_url]})"
  )
end

def add_comment_to_issue!(card_id)
  github_client.add_comment(GITHUB_REPO_NWO,
    args[:issue_number],
    "Beep boop. I saw you labeled this issue with `#{MAGIC_LABEL_NAME}` \
     so I've added it to [the shared project board](#{GITHUB_PROJECT_BOARD_URL}).\
     \n\n<sub>Card ID: #{card_id}</sub>"
  )
end

# Script begin

puts "Arguments: #{args.to_h}"

unless event_for_magic_label?
  puts "Label is not interesting. Bailing!"
  exit 0
end

puts "Adding note to project board..."

created_card = add_card_to_board!

puts "Adding comment to issue..."

add_comment_to_issue!(created_card.id)

puts "Done!"
