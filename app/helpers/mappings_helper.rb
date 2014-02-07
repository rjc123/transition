module MappingsHelper

  ##
  # Twitter bootstrap-flavour tabs.
  # Produce a <ul class="nav nav-tabs">
  # with list items with links in them.
  # e.g.
  #
  #   +bootstrap_flavour_tabs(
  #      {
  #        'Edit'    => edit_path,
  #        'History' => history_path
  #      }, active: 'Edit'
  #    )
  def bootstrap_flavour_tabs(titles_to_links, options)
    content_tag :ul, class: 'nav nav-tabs' do
      titles_to_links.inject('') do |result, title_link|
        title, href       = title_link[0], title_link[1]
        active            = options[:active] == title
        html_opts         = {}
        html_opts[:class] = 'active' if active

        result << content_tag(:li, html_opts) do
          link_to(title, active ? '#' : href)
        end
      end.html_safe
    end
  end

  ##
  # Tabs for mapping editing
  def mapping_edit_tabs(options = {})
    if @mapping.versions.any?
      content_tag :div, class: 'add-bottom-margin' do
        bootstrap_flavour_tabs(
          {
            'Edit'    => edit_site_mapping_path(@mapping.site, @mapping),
            'History' => site_mapping_versions_path(@mapping.site, @mapping)
          },
          options)
      end
    end
  end

  OTHER_OPERATIONS = { 'tag' => 'tag' }
  def http_status_name(http_status)
    Mapping::TYPES[http_status].try(:titleize)
  end

  ##
  # Convert '301'/'410'/tag into 'Redirect'/'Archive'/'Tag' to use in title and heading
  # for edit_multiple
  def operation_name(operation)
    http_status_name(operation) || OTHER_OPERATIONS[operation].titleize
  end

  DEFAULT_FILTER_FIELD = 'path'
  def filter_box_selected?(query_parameter, field_name)
    if query_parameter.blank?
      field_name == DEFAULT_FILTER_FIELD
    else
      query_parameter == field_name
    end
  end

  def existing_mappings_count
    @bulk_add.existing_mappings.size
  end
end
