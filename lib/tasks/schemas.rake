desc "Create new db/schema files using the migrations.  Requires schema_generator."
task :schemas do
  `./script/generate schema --force`
  `sed s/ENGINE=InnoDB/TYPE=MyISAM/ < db/schema.mysql.sql > db/schema.mysql-v3.sql`
  `rm db/schema.rb`
end

namespace :bootstrap do
  desc "initialize objects needed by the app to run smoothly"
  task :setup => :environment do
    Typo::Bootstrap.setup
  end

  desc "warning!!!!, this will remove all intiialized objects in the db"
  task :teardown => :environment do
    Typo::Bootstrap.teardown
  end
end
