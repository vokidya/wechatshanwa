class AddColumToWechatLog < ActiveRecord::Migration
  def change
    add_column :wechatlogs, :log_recognition, :string
  end
end
