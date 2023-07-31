module WordsCountConcerns
  module WordsDelta

    def calculate_delta(count, range)
      if count > range.end
        count - range.end
      elsif count < range.begin
        count - range.begin
      else
        0
      end
    end

  end
end
