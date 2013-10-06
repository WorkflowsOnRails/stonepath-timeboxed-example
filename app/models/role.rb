class Role < ActiveRecord::Base
  has_many :users

  def self.developer
    Role.get('developer')
  end

  def self.deployer
    Role.get('deployer')
  end

  def self.reporter
    Role.get('reporter')
  end

  def developer?
    name == 'developer'
  end

  def deployer?
    name == 'deployer'
  end

  def reporter?
    name == 'reporter'
  end

  private

  def self.get(name)
    Role.where(name: name).take
  end
end
