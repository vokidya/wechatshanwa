class CreateWechatlogs < ActiveRecord::Migration
  def change
    create_table :wechatlogs do |t|
      t.string :logkey
      t.string :logvalue

      t.timestamps null: false
    end
  end
end
