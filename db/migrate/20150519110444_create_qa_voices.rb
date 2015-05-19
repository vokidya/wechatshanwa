class CreateQaVoices < ActiveRecord::Migration
  def change
    create_table :qa_voices do |t|
      t.string :voice_type
      t.string :voice_media_id
      t.string :voice_text

      t.timestamps null: false
    end
  end
end
