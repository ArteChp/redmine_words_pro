module Numberic

  extend ActiveSupport::Concern

  def numberic?(str)
    str == str.to_f.to_s || str == str.to_i.to_s
  end

end
