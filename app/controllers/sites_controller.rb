class SitesController < ApplicationController
  def show
    @site = Site.find_by_abbr!(params[:id])
    @most_used_tags = @site.most_used_tags(10)
    @hosts = @site.hosts.excluding_aka.includes(:aka_host)
    @unresolved_mappings_count = @site.mappings.unresolved.count
  end
end
