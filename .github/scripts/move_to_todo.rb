require "slop"
require "octokit"

MAGIC_LABEL_NAME = "test"
PROJECT_IN_PROGRESS_COLUMN_ID = 10860614
GITHUB_PROJECT_BOARD_URL = "https://github.com/d12/GitHub-Actions-Testing/projects/1"
GITHUB_REPO_NWO = "d12/GitHub-Actions-Testing"

opts = Slop.parse do |o|
  o.string "--action", "The label action taken. One of 'labeled' or 'unlabeled'"
  o.string "--issue_number", "The number of the issue"
  o.string "--github_token", "The GitHub token"
end

puts "Options: #{opts.to_h}"

client = Octokit::Client.new(access_token: opts[:github_token])

unless opts[:action] == "assigned"
  puts "Not an assigned issue."
  exit 0
end

issue = client.issue(GITHUB_REPO_NWO, opts[:issue_number])
if issue.labels.none? { |label| label.name == MAGIC_LABEL_NAME }
  puts "No magic labels on the issue."
  exit 0
end

puts "Searching for Project Card ID..."

comments = client.issue_comments(GITHUB_REPO_NWO, opts[:issue_number])

matching_comment = comments.find_all { |c| /Card ID: \d+/ =~ c.body }.last
unless matching_comment
  puts "Error: Could not find Project Card ID."
  exit 1
end

card_id = /Card ID: (\d+)/.match(matching_comment.body).captures.first
unless card_id
  puts "Error: Could not find Project Card ID. "
  exit 1
end

puts "Found card ID #{card_id}, moving to in progress..."

client.move_project_card(card_id, "bottom", column_id: PROJECT_IN_PROGRESS_COLUMN_ID)

puts "Done!"
