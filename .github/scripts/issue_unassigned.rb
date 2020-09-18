require "slop"
require "yaml"
require_relative "github_client"

def args
  @args ||= Slop.parse do |o|
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

# Script begin

unless github_client.label_on_issue?(issue_number: args[:issue_number], label_name: config["magic_label_name"])
  puts "No magic labels on the issue."
  exit 0
end

card_id = github_client.find_card_id(issue_number: args[:issue_number])

puts "Moving card to todo..."

github_client.move_card_to_column!(card_id: card_id, column_id: config["github_project_todo_column_id"])

puts "Adding comment to issue..."

github_client.add_comment_to_issue!(
  issue_number: args[:issue_number],
  message: "Beep boop. I saw you unassigned this issue so I've moved it to todo \
            on [the shared project board](#{config['github_project_board_url']})."
)

puts "Done!"
