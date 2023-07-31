class VerificationNeed

  attr_accessor :verification_need
  attr_reader :empty_values_array, :previous_doc, :previous_keyword,
              :current_keyword, :attachments, :current_doc, :current_kw_range,
              :previous_kw_range, :current_description_characters_range,
              :previous_description_characters_range, :current_title_characters_range,
              :previous_title_characters_range, :current_attachment_ids

  def initialize(attributes)
    issue = Issue.find_by(id: attributes[:issue_id])

    @empty_values_array = ["\r\n", '', "\n", ' ', nil]
    @verification_need = false
    @previous_doc = issue.google_document.previous
    @previous_keyword = issue.keyword.previous
    @current_keyword = issue.keyword.current
    @attachments = attributes[:attachments]
    @current_doc = issue.google_document.current
    @current_kw_range = issue.kw_range.current
    @previous_kw_range = issue.kw_range.previous
    @current_description_characters_range = issue.description_characters_range.current
    @previous_description_characters_range = issue.description_characters_range.previous
    @current_title_characters_range = issue.title_characters_range.current
    @previous_title_characters_range = issue.title_characters_range.previous
    @current_attachment_ids = attributes[:current_attachment_ids]
  end

  def edit_after_save
    verification_need = !(google_doc_fixity? && keyword_fixity? && attachments_fixity? && kw_range_fixity?)
    unless verification_need
      verification_need = description_characters_range_changed?
    end
    unless verification_need
      verification_need = title_characters_range_changed?
    end
    verification_need
  end

  def after_click
    !empty_values_array.include?(current_keyword)
  end

  def new_after_save
    !empty_values_array.include?(current_keyword)
  end

  private

  def attachments_fixity?
    attachments_empty? || absent_new_attachments?
  end

  def absent_new_attachments?
    attr_ids = attachments.collect(&:id)
    (attr_ids & current_attachment_ids) == attr_ids
  end

  def attachments_empty?
    attachments.nil? || attachments.empty?
  end

  def google_doc_fixity?
    previous_doc == current_doc
  end

  def keyword_fixity?
    previous_keyword == current_keyword
  end

  def description_characters_range_changed?
    current_description_characters_range != previous_description_characters_range
  end

  def title_characters_range_changed?
    current_title_characters_range != previous_title_characters_range
  end

  def kw_range_fixity?
    current_kw_range == previous_kw_range
  end

end
