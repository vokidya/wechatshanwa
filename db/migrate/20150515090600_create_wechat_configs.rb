class CreateWechatConfigs < ActiveRecord::Migration
  def change
    create_table :wechat_configs do |t|
      t.string :key_name
      t.string :key_value
      t.string :key_expired_time

      t.timestamps null: false
    end
  end
end
