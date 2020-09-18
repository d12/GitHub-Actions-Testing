require "slop"
require "yaml"
require_relative "../github_client"

class BaseHandler
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

  def args
    raise NotImplemetedError
  end
end
