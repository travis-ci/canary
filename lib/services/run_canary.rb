require 'services/find_build'
require 'services/create_commit'
require 'digest/sha1'

class RunCanary
  attr_reader :repository, :github_token

  def initialize(repository, github_token)
    @repository, @github_token = repository, github_token
  end

  def run
    message = unique_identifier
    puts "Starting a new canary cycle with build message #{message}"
    create_commit(message)
    build = wait_for_build(message)
    puts "Found build #{build}"
  end

  def unique_identifier
    Digest::SHA1.hexdigest "#{Time.now}-#{rand}"
  end

  def create_commit(message)
    create_commit_service.run(message)
  end

  def wait_for_build(message, &blk)
    build = nil
    loop do
      build = find_build(message)
      puts "Build doesn't exist yet, sleeping"
      if not build
        sleep 5
      else
        return
      end
    end
    build
  end

  def find_build(message)
    find_build_service.run(repository, message)
  end

  def create_commit_service
    @create_commit_service ||= CreateCommit.new(github_token, repository)
  end

  def find_build_service
    @find_build_service ||= FindBuild.new
  end
end

if __FILE__ == $0
  RunCanary.new('travis-ci/canary', ENV['GITHUB_OAUTH_TOKEN']).run
end
