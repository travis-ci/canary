require 'gh'

class CreateCommit
  attr_reader :repository, :gh

  def initialize(token, repository)
    @repository = repository
    @gh = GH.with(token: token)
  end

  def run(message)
    gh.post("repos/#{repository}/git/commits", commit(message))
  rescue GH::Error => e
    puts e.message
  end

  def commit(message)
    {
      parents: [parent],
      tree: tree(parent),
      message: message
    }
  end

  def tree(sha)
    gh.get("repos/#{repository}/git/commits/#{sha}")['commit']['tree']
  rescue GH::Error => e
    puts e.message
  end

  def parent
    gh.get("repos/#{repository}/git/commits?sha=master").first['sha']
  end
end
