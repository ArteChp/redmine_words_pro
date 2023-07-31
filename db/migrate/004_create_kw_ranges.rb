class CreateKwRanges < ActiveRecord::Migration[5.2]
  def change
    create_table :kw_ranges do |t|
      t.text :kw_range
      t.text :kw_range_type
      t.references :issue, index: true, foreign_key: true

      t.timestamps
    end
  end
end
