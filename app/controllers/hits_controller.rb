class HitsController < ApplicationController
  before_filter :find_site, :set_period

  def index
    @category = View::Hits::Category['all'].tap do |c|
      c.hits   = hits_in_period.by_path_and_status.page(params[:page]).order('count DESC')
      c.points = totals_in_period
    end
  end

  def summary
    @sections = View::Hits::Category.all.reject { |c| c.name == 'all' }.map do |category|
      category.tap do |c|
        hits = hits_in_period.by_path_and_status.send(c.to_sym).order('count DESC')

        site = self.find_site

        case c.name
        when 'errors'
          errors = hits.select { |hit| hit.has_mapping?(site) == false }
          c.hits = errors.take(10)
        when 'archives'
          archives = hits.select { |hit| hit.has_archive_mapping?(site) == true }
          c.hits = archives.take(10)
        when 'redirects'
          redirects = hits.select { |hit| hit.has_redirect_mapping?(site) == true }
          c.hits = redirects.take(10)
        else
          c.hits = hits.top_ten.to_a
        end

      end
    end

    unless @period.single_day?
      @point_categories = View::Hits::Category.all.reject { |c| c.name == 'other' }.map do |category|
        category.tap do |c|
          c.points = ((c.name == 'all') ? totals_in_period : totals_in_period.send(category.to_sym))
        end
      end
    end
  end

  def category
    # Category - one of %w(archives redirect errors other) (see routes.rb)
    @category = View::Hits::Category[params[:category]].tap do |c|

      site = self.find_site

      case c.name
      when 'errors'
        c.hits = Kaminari.paginate_array(hits_in_period.by_path_and_status.send(c.to_sym).order('count DESC').select { |hit| hit.has_mapping?(site) == false }).page(params[:page])
      when 'archives'
        c.hits = Kaminari.paginate_array(hits_in_period.by_path_and_status.send(c.to_sym).order('count DESC').select { |hit| hit.has_archive_mapping?(site) == true }).page(params[:page])
      when 'redirects'
        c.hits = Kaminari.paginate_array(hits_in_period.by_path_and_status.send(c.to_sym).order('count DESC').select { |hit| hit.has_redirect_mapping?(site) == true }).page(params[:page])
      else
        c.hits = hits_in_period.by_path_and_status.send(c.to_sym).page(params[:page]).order('count DESC')
      end

      c.points = params[:category] == 'other' ? totals_in_period.by_date.other : totals_in_period.by_date_and_status.send(c.to_sym)
    end
  end

  protected

  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def set_period
    @period = (View::Hits::TimePeriod[params[:period]] || View::Hits::TimePeriod.default)
  end

  def hits_in_period
    @site.hits.in_range(@period.start_date, @period.end_date)
  end

  def totals_in_period
    @site.daily_hit_totals.by_date.in_range(@period.start_date, @period.end_date)
  end
end
