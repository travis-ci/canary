require 'gh'
require 'yaml'
require 'base64'

class CreateCommit
  attr_reader :repository, :gh

  def initialize(token, repository)
    @repository = repository
    @gh = GH.with(token: token)
  end

  def run(message)
    commit = gh.put("repos/#{repository}/contents/.travis.yml", commit(message))
    puts "Created commit #{commit['commit']['sha']}"
  rescue GH::Error => e
    puts e.message
  end

  def commit(message)
    {
      message: message,
      content: Base64.strict_encode64(travis_yaml),
      branch: 'canary',
      sha: parent('canary')
    }
  end

  def travis_yaml
    YAML.dump({
      language: 'ruby',
      rvm: '2.1',
      script: "echo Canary away!",
      install: '/bin/true',
      notifications: {
        email: false
      }
    })
  end

  def parent(branch)
    gh["repos/#{repository}/contents/.travis.yml?ref=#{branch}"]['sha']
  end
end
