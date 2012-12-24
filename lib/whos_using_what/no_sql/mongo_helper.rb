require_relative '../base'

class MongoHelper < Base

  require 'mongo'
  require 'uri'
  require 'json'
  require 'yaml'

  include Mongo

  def self.get_connection
    return @db_connection if @db_connection
    db = URI.parse(ENV["mongo.uri"].strip)
    db_name = db.path.gsub(/^\//, '')
    @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
    @db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
    @db_connection

  end

  if (ENV["mongo.uri"] == nil)
    @li_config = YAML.load_file(File.expand_path("../../config/mongo.env", __FILE__))
    ENV["mongo.host"]= @li_config["mongo.host"]
    ENV["mongo.port"]= @li_config["mongo.port"].to_s
    ENV["mongo.user"]= @li_config["mongo.user"]
    ENV["mongo.pass"]= @li_config["mongo.pass"]
    ENV["mongo.dbname"] = @li_config["mongo.dbname"]
    ENV["mongo.uri"] = "mongodb://" << ENV["mongo.user"] << ":" << ENV["mongo.pass"] << "@" <<
        ENV["mongo.host"] <<":" << ENV["mongo.port"] <<"/" << ENV["mongo.dbname"]

  end

  get_connection


  def self.get_mongo_connection
    @db_connection
  end

end
