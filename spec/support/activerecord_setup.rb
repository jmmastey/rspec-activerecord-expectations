require 'active_record'

if ENV['SHOW_QUERIES'] == '1'
  ActiveRecord::Base.logger = Logger.new(STDERR, level: Logger::DEBUG)
else
  ActiveRecord::Base.logger = Logger.new(STDERR, level: Logger::INFO)
end

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "rspec_activerecord_expectations_test",
  timeout: 5000,
)

ActiveRecord::Schema.define do
  self.verbose = false

  drop_table :albums, if_exists: true
  create_table :albums do |table|
    table.column :title, :string
    table.column :performer, :string
  end

  drop_table :tracks, if_exists: true
  create_table :tracks do |table|
    table.column :album_id, :integer
    table.column :track_number, :integer
    table.column :title, :string
  end

  drop_table :labels, if_exists: true
  create_table :labels do |table|
    table.column :name, :string, null: false
  end

  drop_table :genres, if_exists: true
  create_table :genres do |table|
    table.column :name, :string
  end
end

class Album < ActiveRecord::Base
  has_many :tracks
end

class Track < ActiveRecord::Base
  belongs_to :album
end

class Label < ActiveRecord::Base
  validates :name, presence: true
end

module Categories
  class Genre < ActiveRecord::Base
    self.table_name = :genres
  end
end
