# issue_closed.rb
# Runs when an issue is closed.

require "slop"
require "octokit"

MAGIC_LABEL_NAME = "test"
GITHUB_PROJECT_DONE_COLUMN_ID = 10860615
GITHUB_PROJECT_BOARD_URL = "https://github.com/d12/GitHub-Actions-Testing/projects/1"
GITHUB_REPO_NWO = "d12/GitHub-Actions-Testing"

def args
  @args ||= Slop.parse do |o|
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

def magic_label_on_issue?
  issue = github_client.issue(GITHUB_REPO_NWO, args[:issue_number])
  issue.labels.any? { |label| label.name == MAGIC_LABEL_NAME }
end

def find_card_id
  comments = github_client.issue_comments(GITHUB_REPO_NWO, args[:issue_number])
  return unless comments

  matching_comment = comments.find_all { |c| /Card ID: \d+/ =~ c.body }.last
  return unless matching_comment

  /Card ID: (\d+)/.match(matching_comment.body).captures.first
end

def move_card_to_done!(card_id)
  github_client.move_project_card(card_id, "top", column_id: GITHUB_PROJECT_DONE_COLUMN_ID)
end

def add_comment_to_issue!
  github_client.add_comment(GITHUB_REPO_NWO,
    args[:issue_number],
    "Beep boop. I saw you closed this issue so I've moved it to done \
     on [the shared project board](#{GITHUB_PROJECT_BOARD_URL})."
  )
end

# Script begin

puts "Arguments: #{args.to_h}"

unless magic_label_on_issue?
  puts "Label is not interesting. Bailing!"
  exit 0
end

puts "Moving note to the done column"

move_card_to_done!(find_card_id)

add_comment_to_issue!

puts "Done!"
