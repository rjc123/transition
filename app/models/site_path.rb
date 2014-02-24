class SitePath < ActiveRecord::Base
  belongs_to :site
  belongs_to :mapping
end
