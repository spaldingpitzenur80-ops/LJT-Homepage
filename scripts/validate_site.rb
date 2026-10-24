# frozen_string_literal: true

require 'yaml'
require 'uri'
require 'nokogiri'

config = YAML.safe_load_file('_config.yml')
publications = YAML.safe_load_file('_data/publications.yml')
expected_pages = %w[index.html publications/index.html].sort
actual_pages = Dir.glob('_site/**/*.html').map { |path| path.delete_prefix('_site/') }.sort
abort "Unexpected HTML pages: #{actual_pages.inspect}" unless actual_pages == expected_pages
abort 'Expected exactly six publications' unless publications.length == 6

site_root = config.fetch('url') + config.fetch('baseurl')
site_host = URI(config.fetch('url')).host
baseurl = config.fetch('baseurl')
placeholder_strings = [
  'Your Name', 'Your Sidebar Name', 'Red Brick University', 'none@example.org',
  'PS_CX0AAAAAJ', 'yourorcidurl', 'Name Name', 'Paper Title Number',
  'profile.png', 'og-image.png'
]

expected_pages.each do |relative_path|
  html = File.read(File.join('_site', relative_path))
  document = Nokogiri::HTML(html)
  content = document.at_css('.page__content') or abort "Missing main content: #{relative_path}"
  text = content.text.gsub(/\s+/, ' ')
  entries = content.css('.publication-list > .publication-item')
  abort "Missing publication records: #{relative_path}" unless entries.length == publications.length

  publications.zip(entries).each do |publication, entry|
    entry_text = entry.text.gsub(/\s+/, ' ')
    [publication.fetch('title'), "#{publication.fetch('venue')} #{publication.fetch('year')}",
     publication.fetch('role'), *publication.fetch('authors')].each do |value|
      abort "Missing #{value.inspect} in #{relative_path}" unless entry_text.include?(value)
    end
    if publication['code_repository']
      abort 'Missing recorded code repository name' unless entry_text.include?(publication['code_repository'])
    end
  end

  placeholder_strings.each do |placeholder|
    abort "Template placeholder in #{relative_path}: #{placeholder}" if html.include?(placeholder)
  end
  abort "Unrendered Liquid in #{relative_path}" if html.include?('{%') || html.include?('{{')
  abort 'No portrait was supplied' unless document.css('.author__avatar img').empty?

  page_url = if relative_path == 'index.html'
               site_root + '/'
             else
               site_root + '/' + File.dirname(relative_path) + '/'
             end
  canonical = document.at_css('link[rel="canonical"]')
  abort 'Incorrect project canonical URL' unless canonical && canonical['href'] == page_url

  links = document.css('a[href], link[href], script[src], img[src]')
  links.each do |element|
    address = element['href'] || element['src']
    target_uri = URI.join(page_url, address)
    next unless %w[http https].include?(target_uri.scheme) && target_uri.host == site_host

    path = target_uri.path
    unless path == baseurl || path.start_with?(baseurl + '/')
      abort "Link escapes the project base path: #{address}"
    end
    target_relative = path.delete_prefix(baseurl).sub(%r{\A/}, '')
    target_relative += 'index.html' if target_relative.empty? || target_relative.end_with?('/')
    target_path = File.join('_site', target_relative)
    target_path = File.join(target_path, 'index.html') if File.directory?(target_path)
    abort "Broken internal link: #{address}" unless File.file?(target_path)

    if target_uri.fragment && !target_uri.fragment.empty? && target_path.end_with?('.html')
      target_document = Nokogiri::HTML(File.read(target_path))
      anchor_exists = target_document.css('[id], a[name]').any? do |node|
        node['id'] == target_uri.fragment || node['name'] == target_uri.fragment
      end
      abort "Broken internal anchor: #{address}" unless anchor_exists
    end
  end

  if relative_path == 'index.html'
    ['Skills and research interests', 'Academic background', 'Research experience',
     'Publications', 'Contact', 'Zhiyuan Honor Scholarship', 'MINIMAX',
     'Tencent WXG', 'Shanghai AI Lab', 'Zifei Shan', 'Prof. Yu Cheng',
     'Professor Junxian He', 'first-year PhD candidate', 'June 2024'].each do |value|
      abort "Missing About content: #{value}" unless text.include?(value)
    end
    expected_contacts = [
      'mailto:jliugi@connect.ust.hk', 'https://github.com/Vicent0205',
      config.fetch('author').fetch('googlescholar'), 'https://x.com/junteng88716710'
    ]
    contact_links = content.css('a[href]').map { |link| link['href'] }
    abort 'Missing contact link' unless (expected_contacts - contact_links).empty?
  end
end

puts 'Validated: only About and Publications; six complete publications on both pages; no template placeholders; contact links, internal links, and project URLs are correct.'
