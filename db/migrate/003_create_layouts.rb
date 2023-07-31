class CreateLayouts < ActiveRecord::Migration[5.2]
  def change
    create_table :layouts do |t|
      t.text :layout
      t.references :issue, index: true, foreign_key: true

      t.timestamps
    end
  end
end
