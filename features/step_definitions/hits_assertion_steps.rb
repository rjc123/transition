Then(/^I should see all hits for the Attorney General's office in descending count order$/) do
  within '.hits' do
    counts = page.all(:css, 'td.count').map { |node| node.text.to_i }

    expect(counts).to be_sorted.descending
  end
end

Then(/^I should not see hits for the Cabinet Office site$/) do
  within '.hits' do
    expect(page).to_not have_content('/cabinetoffice')
  end
end

Then(/^the hits should be grouped by path and status$/) do
  within '.hits' do
    expect(page).to have_selector('tbody tr', count: 4)
    expect(page).to have_selector('tbody tr:first-child .count', text: '300')
  end
end

Then(/^the top hit should be represented by a 100% bar$/) do
  within '.hits' do
    expect(page).to have_selector('tbody tr:first-child .bar-chart-row[style*="width: 100"]')
  end
end

Then(/^subsequent hits should have smaller bars$/) do
  within '.hits' do
    expect(page).to have_selector('tbody tr:nth-child(2) .bar-chart-row[style*="width: 66.6"]')
  end
end

Then(/^each path should be a link to the real URL$/) do
  within '.hits' do
    anchors = page.all(:css, '.path a')
    expect(anchors).to have(4).links
  end
end

Then(/^I should see a section for the most common (\w+)$/) do |category|
  expect(page).to have_selector('h2', text: category.titleize)
end

Then(/^it should show(?: only the top) (\d+) (\w+) in descending count order$/) do |count, category|

  case category
  when 'errors'
    status = 404
  when 'archives'
    status = 410
  when 'redirects'
    status = 301
  end

  within ".hits-summary-#{category}" do
    expect(page).to have_sorted_bar_rows(count).for_status(status)
  end
end

Then(/^I should see a graph representing hits data over time$/) do
  expect(page).to have_selector('.hits-graph svg')
end

Then(/^I should not see a graph$/) do
  expect(page).not_to have_selector('.hits-graph svg')
end

Then(/^I should see a trend for all hits, errors, archives and redirects$/) do
  ['#333333', '#ee9999', '#99ee99', '#aaaaaa'].each do |color|
    expect(page).to have_selector("path[stroke='#{color}']")
  end

  ['All hits', 'Errors', 'Archives', 'Redirects'].each do |category|
    expect(page).to have_svg_text(category)
  end
end

Then(/^I should see all hits with a[n]? (\w+) status for the Attorney General's office in descending count order$/) do |category|

  case category
  when 'error'
    status = 404
  when 'archive'
    status = 410
  when 'redirect'
    status = 301
  end

  within '.hits' do
    expect(page).to have_sorted_bar_rows(11).for_status(status)
  end
end

Then(/^each hit should have a link to check its mapping$/) do
  within '.hits tbody' do
    page.all('tr').each do |row|
      path = row.find(:css, '.path').text
      mapping = row.find(:css, '.action')
      expect(mapping).to have_link('', href: site_mapping_find_path(@site, path: path))
    end
  end
end

Then(/^I should be on the add mapping page$/) do
  step 'I should see "Add mapping"'
end

Then(/^the top hit's canonicalized path should already be in the form$/) do
  expect(find_field('Old URL').value).to eql('/a')
end

Then(/^I should see a[n]? (\w+) graph showing a (\w+) trend line(?: with )?([0-9]*)?(?: points)?$/) do |category, color, points|

  case color
  when 'red'
    color = '#ee9999'
  when 'green'
    color = '#99ee99'
  else
    color = '#aaaaaa'
  end

  # Poltergeist doesnt correctly find content of SVG text elements
  # Use an SVG matcher instead of:
  # expect(page).to have_selector('text', text: 'Errors')

  expect(page).to have_svg_text(category.titleize)
  expect(page).to have_selector("path[stroke='#{color}']")

  expect(page).to have_hit_graph_points(points.to_i) if points.present?
end

Then(/^I should see only yesterday's errors in descending count order$/) do
  within '.hits' do
    expect(page).to have_sorted_bar_rows(9).for_status(404)
  end
end

Then(/^the period "([^"]*)" should be selected$/) do |period_title|
  within '.date-range .dropdown-toggle' do
    expect(page).to have_text(period_title)
  end
end

Then(/^I should not see any errors that were fixed$/) do
  steps %{
    Then I should see "/error"
    But I should not see "/was_error_now_redirect"
    And I should not see "/was_error_now_archive"
  }
end

And(/^I should see that I can add mappings where they are missing$/) do
  # There should be an "Add mapping button" for all the missing mappings
  within '.hits-summary-errors' do
    expect(page).to have_link('Add mapping')
  end
end

But(/^I should see all redirects and archives, even those that have since changed type$/) do
  steps %{
    Then I should see "/was_archive_now_redirect"
    And I should see "/always_an_archive"
    And I should see "/always_a_redirect"
    And I should see "/was_redirect_now_archive"
  }
end

And(/^I should see an indication that they have since changed$/) do
  steps %{
    Then I should see "was archived, now redirecting"
    And I should see "was redirecting, now archived"
  }
end

And(/^I should see that I can edit redirects and archives$/) do
  within '.hits-summary-archives' do
    expect(page).to have_link('Edit mapping')
  end
  within '.hits-summary-redirects' do
    expect(page).to have_link('Edit mapping')
  end
end
