require "slop"
require "octokit"

MAGIC_LABEL_NAME = "test"
GITHUB_PROJECT_TODO_COLUMN_ID = 10860613
GITHUB_PROJECT_BOARD_URL = "https://github.com/d12/GitHub-Actions-Testing/projects/1"
GITHUB_REPO_NWO = "d12/GitHub-Actions-Testing"

opts = Slop.parse do |o|
  o.string "--label_name", "The name of the label we're being notified about"
  o.string "--action", "The label action taken. One of 'labeled' or 'unlabeled'"
  o.string "--issue_title", "The title of the issue"
  o.string "--issue_url", "The URL of the issue"
  o.string "--issue_number", "The number of the issue"
  o.string "--github_token", "The GitHub token"
end

puts "Options: #{opts.to_h}"

client = Octokit::Client.new(access_token: opts[:github_token])

unless opts[:label_name] == MAGIC_LABEL_NAME
  puts "Label is not interesting. Bailing!"
  exit
end

unless opts[:action] == "labeled"
  puts "Label was removed, not added. Bailing!"
  exit
end

puts "Adding note to project board..."

created_card = client.create_project_card(GITHUB_PROJECT_TODO_COLUMN_ID,
  note: "(**From Borg**) [#{opts[:issue_title]}](#{opts[:issue_url]})"
)

puts "Adding comment to issue..."

client.add_comment(GITHUB_REPO_NWO,
  opts[:issue_number],
  "Beep boop. Because this was labeled with #{MAGIC_LABEL_NAME}, \
   I've added it to [the shared project board](#{GITHUB_PROJECT_BOARD_URL}).\
   \n\n<sub>Card ID: #{created_card.id}</sub>"
)

puts "Done!"
