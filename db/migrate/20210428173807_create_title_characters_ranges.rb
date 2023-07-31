class CreateTitleCharactersRanges < ActiveRecord::Migration[5.2]
  def change
    create_table :title_characters_ranges do |t|
      t.string :current
      t.string :previous
      t.string :range_type
      t.references :issue, index: true, foreign_key: true

      t.timestamps
    end
  end
end
