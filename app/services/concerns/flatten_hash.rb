module FlattenHash

  extend ActiveSupport::Concern

  def flatten_hash(hash)
    h = {}
    hash.each do |k, v|
      if k == 'custom_field_values'
        v.each do |v_k, v_v|
          h[CustomField.find(v_k).name.to_s] = v_v
        end
      else
        h[k] = v
      end
    end
    h
  end

end
