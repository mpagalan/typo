namespace :db do
  namespace :backup do
    
    def interesting_tables
      ActiveRecord::Base.connection.tables.sort.reject! do |tbl|
        ['schema_migrations'].include?(tbl)
      end
    end
  
    desc "Dump entire db."
    task :write => :environment do 

      dir = RAILS_ROOT + '/db/backup'
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir)
    
      interesting_tables.each do |tbl|
        begin
          klass = tbl.classify.constantize
          puts "Writing #{tbl}..."
          File.open("#{tbl}.yml", 'w+') { |f| YAML.dump klass.find(:all).collect(&:attributes), f }
        rescue Exception => e
          puts e.inspect
        end
      end
    
    end
  
    task :read => :environment do 

      dir = RAILS_ROOT + '/db/backup'
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir)
    
      interesting_tables.each do |tbl|

        klass = tbl.classify.constantize
        ActiveRecord::Base.transaction do 
        
          puts "Loading #{tbl}..."
          YAML.load_file("#{tbl}.yml").each do |fixture|
            ActiveRecord::Base.connection.execute "INSERT INTO #{tbl} (#{fixture.keys.join(",")}) VALUES (#{fixture.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})", 'Fixture Insert'
          end        
        end
      end
    
    end

    task :drop => :environment do
      s = interesting_tables
      s.each do |tbl|

        klass = tbl.classify.constantize
        ActiveRecord::Base.transaction do 
          puts "Dropping #{tbl}..."
          ActiveRecord::Base.connection.execute "DROP TABLE #{tbl}", 'Dropping table'
        end
      end
    end
  
  end
end
