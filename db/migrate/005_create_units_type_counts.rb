class CreateUnitsTypeCounts < ActiveRecord::Migration[5.2]
  def change
    create_table :units_type_counts do |t|
      t.text :count
      t.text :units_type
      t.references :issue, index: true, foreign_key: true

      t.timestamps
    end
  end
end
