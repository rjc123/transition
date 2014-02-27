class SitesController < ApplicationController
  before_filter :find_site

  def show
    @period = View::Hits::TimePeriod['last-seven-days']
    hits = @site.hits.in_range(@period.start_date, @period.end_date)
    @errors = hits.by_path_and_status.send(:errors).top_five
  end

private
  def find_site
    @site = Site.find_by_abbr(params[:id])
  end
end
