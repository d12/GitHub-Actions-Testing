require_relative "base_handler"

class IssueLabeled < BaseHandler
  def args
    @args ||= Slop.parse do |o|
      o.string "--label_name", "The name of the label we're being notified about"
      o.string "--issue_title", "The title of the issue"
      o.string "--issue_url", "The URL of the issue"
      o.string "--issue_number", "The number of the issue"
      o.string "--github_token", "The GitHub token"
    end
  end

  # Is this webhook event firing for the magic label?
  def event_for_magic_label?
    args[:label_name] == config['magic_label_name']
  end

  def call
    unless event_for_magic_label?
      puts "Label is not interesting. Bailing!"
      exit 0
    end

    puts "Adding note to project board..."

    created_card = github_client.add_card_to_board!(
      column_id: config["github_project_todo_column_id"],
      note: "(**From Borg**) [#{args[:issue_title]}](#{args[:issue_url]})"
    )

    puts "Adding comment to issue..."

    github_client.add_comment_to_issue!(
      issue_number: args[:issue_number],
      message: "Beep boop. I saw you labeled this issue with `#{config['magic_label_name']}` \
                so I've added it to [the shared project board](#{config['github_project_board_url']}).\
                \n\n<sub>Card ID: #{created_card.id}</sub>"
    )

    puts "Done!"
  end
end

IssueLabeled.new.call
