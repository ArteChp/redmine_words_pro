require 'active_support/core_ext'

module GenerateDocument

  extend ActiveSupport::Concern

  include ExtensionConverter

  PUNCTUATION_MARKS = ['.', '-', ',', '?', '!', ':', ';', '–', "\n"].freeze

  HEADING1 = [
    'Otsikko1', 'Rubrik1', 'Overskrift1', '1عنوان', 'Überschrift1', 'Titre1',
    'Επικεφαλίδα1', 'Başlık1', 'Título1', 'Rubriek1', 'Intestazione1',
    'Nadpis1', 'Nagłówek1', 'Bóveda1', 'หัวเรื่อง1', 'Tiêu đề1', '标题1', '표제1',
    'Tajuk1', 'Heading1'
  ]

  HEADING2 = [
    'Otsikko2', 'Rubrik2', 'Overskrift2', '2عنوان', 'Überschrift2', 'Titre2',
    'Επικεφαλίδα2', 'Başlık2', 'Título2', 'Rubriek2', 'Intestazione2',
    'Nadpis2', 'Nagłówek2', 'Bóveda2', 'หัวเรื่อง2', 'Tiêu đề2', '标题2', '표제2',
    'Tajuk2', 'Heading2'
  ]

  HEADING3 = [
    'Otsikko3', 'Rubrik3', 'Overskrift3', '3عنوان', 'Überschrift3', 'Titre3',
    'Επικεφαλίδα3', 'Başlık3', 'Título3', 'Rubriek3', 'Intestazione3',
    'Nadpis3', 'Nagłówek3', 'Bóveda3', 'หัวเรื่อง3', 'Tiêu đề3', '标题3',
    '표제3', 'Tajuk3', 'Heading3'
  ]

  HEADING4 = [
    'Otsikko4', 'Rubrik4', 'Overskrift4', '4عنوان', 'Überschrift4', 'Titre4',
    'Επικεφαλίδα4', 'Başlık4', 'Título4', 'Rubriek4', 'Intestazione4',
    'Nadpis4', 'Nagłówek4', 'Bóveda4', 'หัวเรื่อง4', 'Tiêu đề4', '标题4', '표제4',
    'Tajuk4', 'Heading4'
  ]

  HEADING5 = [
    'Otsikko5', 'Rubrik5', 'Overskrift5', '5عنوان', 'Überschrift5', 'Titre5',
    'Επικεφαλίδα4', 'Başlık5', 'Título5', 'Rubriek5', 'Intestazione5',
    'Nadpis5', 'Nagłówek5', 'Bóveda5', 'หัวเรื่อง5', 'Tiêu đề4', '标题4', '표제4',
    'Tajuk5', 'Heading5'
  ]

  HEADING6 = [
    'Otsikko6', 'Rubrik6', 'Overskrift6', '6عنوان', 'Überschrift6', 'Titre6',
    'Επικεφαλίδα6', 'Başlık6', 'Título6', 'Rubriek6', 'Intestazione6',
    'Nadpis6', 'Nagłówek6', 'Bóveda6', 'หัวเรื่อง6', 'Tiêu đề6', '标题6', '표제6',
    'Tajuk6', 'Heading6'
  ]

  HEADING1_REGEX = %r{<h1>(.*?)<\/h1>}
  HEADING2_REGEX = %r{/<h2>(.*?)<\/h2>}
  HEADING3_REGEX = %r{/<h3>(.*?)<\/h3>}
  HEADING4_REGEX = %r{<h4>(.*?)<\/h4>}
  HEADING5_REGEX = %r{/<h5>(.*?)<\/h5>}
  HEADING6_REGEX = %r{<h6>(.*?)<\/h6>}

  def generate_document(attachment_id)
    @text_with_location = []

    @paragraph_index = 0
    @heading_index = 0

    @heading1_index = 0
    @heading2_index = 0
    @heading3_index = 0
    @heading4_index = 0
    @heading5_index = 0
    @heading6_index = 0

    convert_file(attachment_id)
    hyperlink_indexes, words = hyperlink_words_and_indexes

    docx_content = []

    unless @docx.nil?
      @docx.paragraphs.each_with_index do |paragraph, index|
        docx_content << paragraph
        if ['<w:pict>', 'v:rect', 'o:hr'].all? { |str| str.include?(paragraph.try(:node).to_s) }
          break
        end
      end

      docx_content.each do |paragraph|
        if paragraph.try(:node) && paragraph.to_s != ' '
          attributes = paragraph.try(:node).try(:children).try(:children).try(:first).try(:attributes)
          val = attributes.nil? ? nil : attributes['val'].try(:value)
          heading_number = get_heading_number(paragraph)
          if heading_number
            @heading_index += 1

            if heading_number == 'h1'
              @heading1_index += 1
              num_h_num = "#{@heading1_index}h1"
            end

            if heading_number == 'h2'
              @heading2_index += 1
              num_h_num = "#{@heading2_index}h2"
            end

            if heading_number == 'h3'
              @heading3_index += 1
              num_h_num = "#{@heading3_index}h3"
            end

            if heading_number == 'h4'
              @heading4_index += 1
              num_h_num = "#{@heading4_index}h4"
            end

            if heading_number == 'h5'
              @heading5_index += 1
              num_h_num = "#{@heading5_index}h5"
            end

            if heading_number == 'h6'
              @heading6_index += 1
              num_h_num = "#{@heading6_index}h6"
            end

            location_hash = {
              num_p: false,
              num_h: "#{@heading_index}h",
              h_num: heading_number,
              num_h_num: num_h_num,
              title: false,
              desc: false,
              p: false,
              h: true
            }

            paragraph.to_s.split(%r{(?<=[\/?.!,:;'" ])}).each do |p|
              p.to_s.strip!
              unless p.to_s.blank? || (PUNCTUATION_MARKS.include? p.to_s)
                @text_with_location << { p => location_hash }
              end
            end
          else
            if paragraph
              @paragraph_index += 1 if is_paragraph?(paragraph)
              paragraph_index = @paragraph_index if is_paragraph?(paragraph)
              location_hash = {
                num_p: paragraph_index,
                num_h: false,
                h_num: false,
                num_h_num: false,
                title: paragraph_is_title?(paragraph),
                desc: paragraph_is_description?(paragraph),
                p: is_paragraph?(paragraph),
                h: false
              }

              # split every word to array with locations
              paragraph.to_s.split(%r{(?<=[\/?.!,:;'" ])}).each do |p|
                p.to_s.strip!
                unless p.to_s.blank? || (PUNCTUATION_MARKS.include? p.to_s)
                  @text_with_location << { p => location_hash }
                end
              end
            end
          end
        end
      end
    end
    add_location_link(hyperlink_indexes, words)
  end

  private

  def paragraph_is_title?(paragraph)
    paragraph.to_s.match("#{Setting.plugin_redmine_keywords['title_regexp']}")
  end

  def paragraph_is_description?(paragraph)
    paragraph.to_s.match("#{Setting.plugin_redmine_keywords['description_regexp']}")
  end

  def is_heading?(paragraph)
    true if get_heading_number(paragraph)
  end

  def is_paragraph?(paragraph)
    !is_heading?(paragraph) && !paragraph_is_description?(paragraph) && !paragraph_is_title?(paragraph)
  end

  def get_heading_type(paragraph)
  end

  def get_heading_number(paragraph)
    if paragraph.try(:node) && paragraph.to_s != ' '
      attributes = paragraph.try(:node).try(:children).try(:children).try(:first).try(:attributes)
      val = attributes.nil? ? nil : attributes['val'].try(:value)
      return 'h1' if val && HEADING1.include?(val)
      return 'h2' if val && HEADING2.include?(val)
      return 'h3' if val && HEADING3.include?(val)
      return 'h4' if val && HEADING4.include?(val)
      return 'h5' if val && HEADING5.include?(val)
      return 'h6' if val && HEADING6.include?(val)
    end
  end

  def add_location_link(hyperlink_indexes, words)
    # add hyperlinks to word by it index
    hyperlink_indexes.each_with_index do |hyperlink_index, index|
      link = words[index].split('"')[1]
      word = words[index].split('"')[2]
      next unless @text_with_location[hyperlink_index]

      hash = @text_with_location[hyperlink_index][word]
      new_word = "(#{link})#{word}"
      new_hash = { new_word => hash }
      @text_with_location[hyperlink_index] = new_hash
    end
  end

  def hyperlink_words_and_indexes
    # get indexes of hyperlink in text
    words, hyperlink_indexes = [], []
    doc_array = @doc_text.split
    while doc_array.include?("HYPERLINK")
      hyperlink_index = doc_array.index("HYPERLINK")
      hyperlink_indexes << hyperlink_index
      words << doc_array[hyperlink_index + 1]
      doc_array.delete_at(hyperlink_index)
    end
    return hyperlink_indexes, words
  end

end
