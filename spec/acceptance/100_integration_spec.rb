require 'timeout'
require 'spec_helper'

# describe 'Atlassian Confluence with Embedded Database', order: :defined do
# 	include_examples 'an acceptable confluence instance', 'using an embedded database'
# end

describe 'Atlassian Confluence with PostgreSQL 9.3 Database', order: :defined do
	include_examples 'an acceptable confluence instance', 'using a postgresql database' do
		unless ENV["CI"] == "true"
			before :all do
				# Create and run a PostgreSQL 9.3 container instance
				@container_db = Docker::Image.create('fromImage' => 'postgres', 'tag' => '9.3').run
				# Wait for the PostgreSQL instance to start
				@container_db.wait_for_output %r{PostgreSQL\ init\ process\ complete;\ ready\ for\ start\ up\.}
				# Create Confluence database
				@container_db.exec ["psql", "--username", "postgres", "--command", "create database confluence owner postgres encoding 'utf8';"]
			end
		else
			before :all do
				@container_db = Docker::Container.get 'postgres'
			end
		end

		after :all do
			@container_db.remove force: true, v: true unless @container_db.nil?
		end
	end
end

# describe 'Atlassian Confluence with MySQL 5.6 Database', order: :defined do
# 	include_examples 'an acceptable confluence instance', 'using a mysql database' do
# 		unless ENV["CI"] == "true"
# 			before :all do
# 				# Create and run a MySQL 5.6 container instance
# 				image = Docker::Image.create('fromImage' => 'mysql', 'tag' => '5.6')
# 				@container_db = Docker::Container.create 'Image' => image.id, 'Env' => ["MYSQL_ROOT_PASSWORD=mysecretpassword"]
# 				@container_db.start!
# 				# Wait for the MySQL instance to start
# 				@container_db.wait_for_output %r{socket:\ '/var/run/mysqld/mysqld\.sock'\ \ port:\ 3306\ \ MySQL\ Community\ Server\ \(GPL\)}
# 				# Create Confluence database
# 				@container_db.exec ['mysql', '--user=root', '--password=mysecretpassword', '--execute', 'CREATE DATABASE confluence CHARACTER SET utf8 COLLATE utf8_bin;']
# 			end
# 		else
# 			@container_db = Docker::Container.get 'mysql'
# 		end

# 		after :all do
# 			@container_db.remove force: true, v: true unless @container_db.nil?
# 		end
# 	end
# end
