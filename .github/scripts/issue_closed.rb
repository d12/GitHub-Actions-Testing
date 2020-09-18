require_relative "base_handler"

class IssueClosed < BaseHandler
  def args
    @args ||= Slop.parse do |o|
      o.string "--issue_number", "The number of the issue"
      o.string "--github_token", "The GitHub token"
    end
  end

  def call
    unless github_client.label_on_issue?(issue_number: args[:issue_number], label_name: config["magic_label_name"])
      puts "Label is not interesting. Bailing!"
      exit 0
    end

    puts "Moving note to the done column..."

    card_id = github_client.find_card_id(issue_number: args[:issue_number])
    github_client.move_card_to_column!(card_id: card_id, column_id: config["github_project_done_column_id"])

    puts "Adding comment to issue..."

    github_client.add_comment_to_issue!(
      issue_number: args[:issue_number],
      message: "Beep boop. I saw you closed this issue so I've moved it to done \
                on [the shared project board](#{config['github_project_board_url']})."
    )

    puts "Done!"
  end
end

IssueClosed.new.call
