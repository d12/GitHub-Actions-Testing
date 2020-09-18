# issue_labeled.rb
# Runs when an issue is labeled.

require "slop"
require "yaml"
require_relative "github_client"

def args
  @args ||= Slop.parse do |o|
    o.string "--label_name", "The name of the label we're being notified about"
    o.string "--issue_number", "The number of the issue"
    o.string "--github_token", "The GitHub token"
  end
end

def config
  @config ||= begin
    YAML.load(File.read("config.yml"))
  end
end

def github_client
  @github_client ||= GithubClient.new(
    github_token: args[:github_token],
    repo_name_with_owner: config["github_repo_name_with_owner"]
  )
end

# Is this webhook event firing for the magic label?
def event_for_magic_label?
  args[:label_name] == config["magic_label_name"]
end

# Script begin

unless event_for_magic_label?
  puts "Label is not interesting. Bailing!"
  exit 0
end

puts "Removing note from project board..."

card_id = github_client.find_card_id(issue_number: args[:issue_number])
result = github_client.remove_card_from_board!(card_id: card_id)

puts "Adding comment to issue..."

github_client.add_comment_to_issue!(
  issue_number: args[:issue_number],
  message: "Beep boop. I saw you removed the #{config['magic_label_name']} label, \
            I've removed this issue from [the shared project board](#{config['github_project_board_url']})."
)

puts "Done!"
