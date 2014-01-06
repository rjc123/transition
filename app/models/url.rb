class URL < ActiveRecord::Base
  belongs_to :host
  # has_many :hits, foreign_key: :path_hash, primary_key: :path_hash, conditions: 'hits.host_id = urls.host_id'
  has_many :hits
  belongs_to :mapping
end
