class CreateKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :keywords do |t|
      t.text :current
      t.text :previous
      t.references :issue, index: true, foreign_key: true

      t.timestamps
    end
  end
end
