application = 'stonepath-example'

set :keep_releases, 3

set :application, application
set :repo_url, 'git@github.com:WorkflowsOnRails/stonepath-timeboxed-example.git'
set :scm, :git
set :branch, 'master'

set :deploy_to, "/srv/#{application}"
set :linked_files, ["config/database.yml"]

set :rails_env, 'staging'
set :migration_role, 'application'


namespace :db do
  desc "Create database yaml in shared path"
  task :configure do
    database_username = 'application'
    database_password = ask(:database_password, "password")

    db_config = <<-EOF
      base: &base
        adapter: sqlite3
        encoding: utf8
        reconnect: false
        pool: 5

      staging:
        database: #{application}_production
        username: #{database_username}
        password: #{database_password.call}
        <<: *base
    EOF

    on roles(:web), in: :groups do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(db_config), "#{shared_path}/config/database.yml"
    end
  end
end


namespace :deploy do
  desc 'Set up deployment target'
  task :setup do
    # TODO
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end


  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end

before "deploy:setup", "db:configure"
