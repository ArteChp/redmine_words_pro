class AddCurrentAndPreviousToKwRanges < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_ranges, :current, :string
    add_column :kw_ranges, :previous, :string

    KwRange.update_all("current=kw_range")
  end
end
