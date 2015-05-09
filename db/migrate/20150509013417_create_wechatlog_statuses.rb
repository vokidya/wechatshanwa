class CreateWechatlogStatuses < ActiveRecord::Migration
  def change
    create_table :wechatlog_statuses do |t|
      t.integer :log_id
      t.string :log_status

      t.timestamps null: false
    end
  end
end
