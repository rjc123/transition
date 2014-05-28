module FilterHelper
  def filter_option_link(site, type, options = {})
    selected = options[:selected]

    link_to filter_site_mappings_path(site),
        'class'         => "filter-option #{'filter-selected' if selected}",
        'data-toggle'   => 'dropdown',
        'role'          => 'button' do
      "#{type} <span class=\"glyphicon glyphicon-chevron-down\"></span>".html_safe
    end
  end

  def filter_remove_option_link(site, type, type_sym)
    link_to site_mappings_path(site, params.except(type_sym, :page)), title: 'Remove filter', class: 'filter-option filter-selected' do
      "<span class=\"glyphicon glyphicon-remove\"></span><span class=\"rm\">Remove</span> #{type}".html_safe
    end
  end

  def sort_by_path_path
    params.except(:page, :sort)
  end

  def sort_by_hits_path
    params.except(:page).merge(sort: 'by_hits')
  end
end
