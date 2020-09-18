require "octokit"

class GithubClient
  class GithubClientError < StandardError; end

  attr_reader :octokit_client, :repo_name_with_owner

  def initialize(github_token:, repo_name_with_owner:)
    @octokit_client ||= begin
      client = Octokit::Client.new(access_token: github_token)
      client.auto_paginate = true

      client
    end

    @repo_name_with_owner = repo_name_with_owner
  end

  ### Projects

  def add_card_to_board!(column_id:, note:)
    octokit_client.create_project_card(column_id, note: note)
  end

  def remove_card_from_board!(card_id:)
    octokit_client.delete_project_card(card_id)
  end

  def move_card_to_column!(card_id:, column_id:)
    octokit_client.move_project_card(card_id, "bottom", column_id: column_id)
  end

  def find_card_id(issue_number:)
    comments = octokit_client.issue_comments(repo_name_with_owner, issue_number)

    matching_comment = comments&.find_all { |c| /Card ID: \d+/ =~ c.body }.last

    unless matching_comment
      raise GithubClientError, "Could not find a comment with the Card ID"
    end

    /Card ID: (\d+)/.match(matching_comment.body).captures.first
  end

  ### Issues

  def add_comment_to_issue!(issue_number:, message:)
    octokit_client.add_comment(
      repo_name_with_owner,
      issue_number,
      message,
    )
  end

  def label_on_issue?(issue_number:, label_name:)
    issue = octokit_client.issue(repo_name_with_owner, issue_number)
    issue.labels.any? { |label| label.name == label_name }
  end


end
