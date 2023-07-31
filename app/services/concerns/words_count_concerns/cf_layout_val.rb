module WordsCountConcerns
  module CfLayoutVal

    extend ActiveSupport::Concern

    # transform kw_range depending on kw_range_type
    def get_cf_layout_val(kw_range_type, kw_range)
      kw_range = kw_range.to_i / 4.7  if kw_range_type == 'Symbols'
      kw_range
    end
  end

end
