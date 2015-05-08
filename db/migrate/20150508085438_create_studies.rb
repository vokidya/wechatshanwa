class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.string :question
      t.string :answer

      t.timestamps null: false
    end
  end
end
