require 'travis'

class FindBuild
  attr_reader :token

  def initialize(token = nil)
    @token = token
  end

  def run(repository_name, message)
    travis = new_client
    repository = travis.repo(repository_name)
    builds = repository.recent_builds.select do |build|
      build.commit.message == message
    end
    builds.first if builds.any?
  end

  def new_client
    Travis::Client.new(access_token: token)
  end
end
