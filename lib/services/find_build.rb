require 'travis'

class FindBuild
  attr_reader :travis

  def initialize(token)
    @travis = Travis::Client.new(access_token: token)
  end

  def run(repository, message)
    builds = travis.repo(repository).builds
    builds.find do |build|
      build.message.include?(mesage)
    end
  end
end
