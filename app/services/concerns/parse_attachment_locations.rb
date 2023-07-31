module ParseAttachmentLocations

  extend ActiveSupport::Concern

  HEADINGS = [
    'w:val="Heading1', 'w:val="Heading2', 'w:val="Heading3', 'w:val="Heading4',
    'w:val="Heading5', 'w:val="Heading6'
  ]

  def attachment_location_text(args = {})
    # get text form text_with_location by given location
    location = args[:location].to_s
    if location.match(/^h[1-6]+$/)
      get_attachment_headers_with_type(args[:text_with_location], args[:doc_text_array], location)
    elsif location.match(/^[1-9][0-9]*w$/)
      get_attachment_words(args[:text_with_location], args[:doc_text_array], args[:location].split('w')[0])
    elsif location == 'h'
      get_attachment_all_headers(args[:text_with_location], args[:doc_text_array])
    elsif location == 'all'
      get_attachment_all(args[:text_with_location], args[:doc_text_array])
    elsif location == 'p'
      get_attachment_all_paragraphs(args[:text_with_location], args[:doc_text_array])
    elsif location.match(/^[1-9]*h$/)
      get_attachment_headers_with_number(args[:text_with_location], args[:doc_text_array], location)
    elsif location.match(/^[1-9]*p$/)
      get_attachment_paragraphs(args[:text_with_location], args[:doc_text_array], location)
    elsif location == 'title'
      get_attachment_title(args[:text_with_location], args[:doc_text_array])
    elsif location == 'desc'
      get_attachment_meta_description(args[:text_with_location], args[:doc_text_array])
    elsif location == 'except_meta'
      get_attachment_except_meta(args[:text_with_location], args[:doc_text_array])
    elsif location == 'every_h'
      get_attachment_every_heading(args[:text_with_location], args[:doc_text_array])
    end
  end

  private

  def get_attachment_all_headers(text_with_location, doc_text_array)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      if line.values[0] && line.values[0][:h]
        text << line.keys[0] + ' '
      end
    end

    text = clean_text(text)
    return text
  end

  def get_attachment_all(text_with_location, doc_text_array)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      text << line.keys[0] + ' '
    end

    text = clean_text(text)
    return text
  end

  def get_attachment_all_paragraphs(text_with_location, doc_text_array)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      if line.values[0] && line.values[0][:p]
        text << line.keys[0] + ' '
      end
    end

    text = clean_text(text)
    return text
  end

  def get_attachment_headers_with_number(text_with_location, doc_text_array, header_number)
    header_number = "#{header_number}h"
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      if line.values[0] && line.values[0][:num_h] == header_number
        text << line.keys[0] + ' '
      end
    end

    text = clean_text(text)
    return text
  end

  def get_attachment_headers_with_type_and_number(text_with_location, doc_text_array, header_number, header_type)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      if line.values[0]
        if line.values[0][:num_h_num] == "#{header_number}h#{header_type}"
          text << line.keys[0] + ' '
        end
      end
    end

    text = clean_text(text)
    return text
  end

  def get_attachment_headers_with_type(text_with_location, doc_text_array, header_type)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      if line.values[0] && line.values[0][:h_num] == header_type
        text << line.keys[0] + ' '
      end
    end
    text = clean_text(text)
    return text
  end

  def get_attachment_meta_description(text_with_location, doc_text_array)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      if line.values[0] && line.values[0][:desc]
        text << line.keys[0] + ' '
      end
    end

    text = desc_match(text).try(:captures).to_a[0].to_s
    text = clean_text(text)
    return text
  end

  def get_attachment_paragraphs(text_with_location, doc_text_array, paragraph_number)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      if line.values[0] && line.values[0][:num_p] == paragraph_number
        text << line.keys[0] + ' '
      end
    end

    text = clean_text(text)
    return text
  end

  def get_attachment_title(text_with_location, doc_text_array)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      if line.values[0] && line.values[0][:title]
        text << line.keys[0] + ' '
      end
    end

    text = title_match(text).try(:captures).to_a[0].to_s
    text = clean_text(text)
    return text
  end

  def get_attachment_words(text_with_location, doc_text_array, words)
    text = ''
    (text_with_location || []).each_with_index do |line, index|
      text << line.keys[0] + ' '
    end

    text = clean_text(text)
    text = text.split(/\W+/)[0..words.to_i].join(' ')
    return text
  end

  def get_attachment_except_meta(text_with_location, doc_text_array)
    text = ''
    if text_with_location
      text_with_location.each_with_index do |line, index|
        if line.values[0] && !line.values[0][:title] && !line.values[0][:desc]
          text << line.keys[0] + ' '
        end
      end
    end

    text.gsub!("\n", ' ')
    text = text.squeeze(' ')
    text.downcase!
    return text
  end

  def get_attachment_every_heading(text_with_location, doc_text_array)
    docx_content = []
    unless @docx.nil?
      @docx.paragraphs.each_with_index do |paragraph, index|
        docx_content << paragraph
        if ['<w:pict>', 'v:rect', 'o:hr'].all? { |str| str.include?(paragraph.try(:node).to_s) }
          break
        end
      end
    end

    headers = []
    docx_content.each do |paragraph|
      if HEADINGS.any? { |h| paragraph.node.to_s.include? h }
        if paragraph && !["\n", ' ', ''].include?(paragraph.to_s)
          headers << paragraph.to_s
        end
      end
    end
    headers.map!(&:downcase)
  end

  def clean_text(text)
    text.gsub!("\n", ' ')
    text = text.squeeze(' ')
    text.downcase!
  end

  def title_match(value)
    title_regexp = Setting.plugin_redmine_keywords['title_regexp']
    value.match(title_regexp)
  end

  def desc_match(value)
    desc_regexp = Setting.plugin_redmine_keywords['description_regexp']
    value.match(desc_regexp)
  end

end
