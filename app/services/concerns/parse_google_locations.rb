module ParseGoogleLocations

  extend ActiveSupport::Concern

  def google_location_text(args = {})
    # get text form google content by given location
    location = args[:location].to_s
    if location.match(/^h[1-6]+$/)
      get_headers_with_type(args[:content], location.split('h')[1])
    elsif location.match(/^[1-9][0-9]*w$/)
      get_words(args[:content], args[:location].split('w')[0])
    elsif location == 'h'
      get_all_headers(args[:content])
    elsif location == 'all'
      get_all(args[:content])
    elsif location == 'p'
      get_all_paragraphs(args[:content])
    elsif location.match(/^[1-9]*h$/)
      get_headers_with_number(args[:content], args[:location])
    elsif location.match(/^[1-9]*p$/)
      get_paragraphs([:content], location)
    elsif location == 'title'
      get_title(args[:content])
    elsif location == 'except_meta'
      get_except_meta(args[:content])
    elsif location == 'every_h'
      get_every_heading(args[:content])
    elsif location == 'desc'
      get_meta_description(args[:content])
    end
  end

  private

  def get_all_headers(content)
    @headings = %w[HEADING_1 HEADING_2 HEADING_3 HEADING_4 HEADING_5 HEADING_6]

    headers = []
    content.each do |value|
      next unless value.paragraph

      if @headings.any? { |h| paragraph_style(value).to_s.include? h }
        value.paragraph.elements.each do |p|
          if p.try(:text_run).try(:text_style).try(:link).nil?
            unless p.text_run.content.to_s == "\n"
              headers << p.text_run.content.to_s
            end
          else
            link_text = p.text_run.content
            link_url = p.text_run.text_style.link.url
            headers << "(#{link_url})#{link_text}"
          end
        end
      end
    end
    text = headers.join(' ')
    clean_text(text)
  end

  def get_all(content)
    text = GoogleDocsAuthorize.new.read_with_links(content)
    clean_text(text)
  end

  def get_all_paragraphs(content)
    normal_text = []
    content.each do |value|
      next unless value.paragraph

      base_content = base_content(value)
      if paragraph_style(value) == 'NORMAL_TEXT' && !(base_content.instance_of? NilClass) &&
         !title_match(base_content.content) && !is_desc?(value)

        value.paragraph.elements.each do |p|
          if p.try(:text_run).try(:text_style).try(:link).nil?
            unless p.text_run.content.to_s == "\n"
              normal_text << p.text_run.content.to_s
            end
          else
            link_text = p.text_run.content
            link_url = p.text_run.text_style.link.url
            normal_text << "(#{link_url})#{link_text}"
          end
        end
      end
    end
    text = normal_text.join(' ')
    clean_text(text)
  end

  def get_headers_with_number(content, headers_number)
    @headings = %w[HEADING_1 HEADING_2 HEADING_3 HEADING_4 HEADING_5 HEADING_6]
    @heading_regex = /(<h1>|<h2>|<h3>|<h4>|<h5>|<h6>)(.*?)(<\/h1>|<\/h2>|<\/h3>|<\/h4>|<\/h5>|<\/h6>)/
    headers = []
    content.each do |value|
      next unless value.paragraph

      if @headings.any? { |h| paragraph_style(value).to_s.include? h }
        value.paragraph.elements.each do |p|
          if p.try(:text_run).try(:text_style).try(:link).nil?
            return if  ["\n", ' ', ''].include? p.text_run.content.to_s
            headers << p.text_run.content.to_s
          else
            link_text = p.text_run.content
            link_url = p.text_run.text_style.link.url
            headers << "(#{link_url})#{link_text}"
          end
        end
      else
        value.paragraph.elements.each do |p|
          headers.concat p.text_run.content.scan(@heading_regex) if p.text_run
        end
      end
    end
    if headers.any?
      text = headers[headers_number.to_i - 1].to_s
      clean_text(text)
    end
    text
  end

  def get_headers_with_type_and_number(content, headers_type, headers_number)
    headers = []
    heading, heading_regex = check_headers_type(headers_type)
    content.each do |value|
      next unless value.paragraph

      if paragraph_style(value) == heading
        header = ''
        value.paragraph.elements.each do |p|
          if p.try(:text_run).try(:text_style).try(:link).nil?
            return if ["\n", ' ', ''].include? p.text_run.content.to_s
            header << p.text_run.content.to_s
          else
            text_link = p.text_run.content
            link_url = p.text_run.text_style.link.url
            header << "(#{link_url})#{text_link}"
          end
        end
        headers << header
      else
        value.paragraph.elements.each do |p|
          headers.concat p.text_run.content.scan(heading_regex) if p.text_run
        end
      end
    end
    headers = headers.reject { |h| h.empty? }
    text = headers[headers_number.to_i - 1].to_s
    clean_text(text)
    text
  end

  def get_headers_with_type(content, headers_type)
    headers = []
    heading, heading_regex = check_headers_type(headers_type)
    content.each do |value|
      next unless value.paragraph

      if paragraph_style(value) == heading
        value.paragraph.elements.each do |p|
          if p.try(:text_run).try(:text_style).try(:link).nil?
            next if ["\n", ' ', ''].include? p.text_run.content.to_s
            headers << p.text_run.content.to_s
          else
            link_text = p.text_run.content
            link_url = p.text_run.text_style.link.url
            headers << "(#{link_url})#{link_text}"
          end
        end
      else
        value.paragraph.elements.each do |p|
          headers.concat p.text_run.content.scan(heading_regex) if p.text_run
        end
      end
    end
    text = headers.join(' ')
    clean_text(text)
  end

  def get_meta_description(content)
    text = GoogleDocsAuthorize.new.read_with_links(content)
    text = desc_match(text).try(:captures).to_a[0].to_s
    text.downcase!
    text
  end

  def get_paragraphs(content, paragraph_number)
    normal_text = []
    content.each do |value|
      next unless value.paragraph

      base_content = base_content(value)
      if paragraph_style(value) == 'NORMAL_TEXT' &&
         !(base_content.instance_of? NilClass) &&
         !title_match(base_content.content) &&
         !is_desc?(base_content.content)

        paragraph = ''
        value.paragraph.elements.each do |p|
          if p.try(:text_run).try(:text_style).try(:link).nil?
            return if ["\n", ' ', ''].include? p.text_run.content.to_s
            paragraph << p.text_run.content.to_s
          else
            paragraph << "#{p.text_run.content}(#{p.text_run.text_style.link.url})"
          end
        end
        normal_text << paragraph
      end
    end
    normal_text.delete('')
    normal_text
  end

  def get_title(content)
    text = GoogleDocsAuthorize.new.read_with_links(content)
    text = title_match(text).try(:captures).to_a[0].to_s
    text.downcase!
    text
  end

  def get_words(content, words)
    text = GoogleDocsAuthorize.new.read_with_links(content)
    text = text.split(' ')[0..words.to_i].join(' ')
    clean_text(text)
    text = text.split(/\W+/)[0..words.to_i].join(' ')
    text
  end

  def get_except_meta(content)
    text = GoogleDocsAuthorize.new.read_with_links(content)
    title_text = title_match(text).try(:captures).to_a[0].to_s
    text.gsub!(title_text, '')
    desc_text = desc_match(text).try(:captures).to_a[0].to_s
    text.gsub!(desc_text, '')
    text.downcase!
    text
  end

  def get_every_heading(content)
    @headings = %w[HEADING_1 HEADING_2 HEADING_3 HEADING_4 HEADING_5 HEADING_6]
    headers = []
    content.each do |value|
      next unless value.paragraph
      if @headings.any? { |h| paragraph_style(value).to_s.include? h }
        value.paragraph.elements.each do |p|
          if p.try(:text_run).try(:text_style).try(:link).nil?
            unless p.text_run.content.to_s == "\n"
              headers << p.text_run.content.to_s
            end
          else
            link_text = p.text_run.content
            link_url = p.text_run.text_style.link.url
            headers << "(#{link_url})#{link_text}"
          end
        end
      end
    end
    headers.map!(&:downcase)
  end

  def check_headers_type(headers_type)
    case headers_type
    when '1'
      heading = 'HEADING_1'
      heading_regex = %r{<h1>(.*?)<\/h1>}
    when '2'
      heading = 'HEADING_2'
      heading_regex = %r{<h2>(.*?)<\/h2>}
    when '3'
      heading = 'HEADING_3'
      heading_regex = %r{<h3>(.*?)<\/h3>}
    when '4'
      heading = 'HEADING_4'
      heading_regex = %r{<h4>(.*?)<\/h4>}
    when '5'
      heading = 'HEADING_5'
      heading_regex = %r{<h5>(.*?)<\/h5>}
    when '6'
      heading = 'HEADING_6'
      heading_regex = %r{<h6>(.*?)<\/h6>}
    end
    return heading, heading_regex
  end

  def base_content(value)
    value.paragraph&.elements&.first&.text_run
  end

  def paragraph_style(value)
    value.paragraph&.paragraph_style&.named_style_type
  end

  def is_normal_text?(value)
    paragraph_style(value) == 'NORMAL_TEXT' && !(base_content.instance_of? NilClass)
  end

  def title_match(value)
    title_regexp = Setting.plugin_redmine_keywords['title_regexp']
    value.match(title_regexp)
  end

  def desc_match(value)
    desc_regexp = Setting.plugin_redmine_keywords['description_regexp']
    value.match(desc_regexp)
  end

  def clean_text(text)
    text.gsub!("\n", ' ')
    text = text.squeeze(' ')
    text.downcase!
  end

  def is_title?(value)
    title_regexp = Setting.plugin_redmine_keywords['title_regexp']
    value.paragraph.elements[0].text_run.content.match(title_regexp.to_s)
  end

  def is_desc?(value)
    desc_regexp = Setting.plugin_redmine_keywords['description_regexp']
    value.paragraph.elements[0].text_run.content.match(desc_regexp.to_s)
  end

end
