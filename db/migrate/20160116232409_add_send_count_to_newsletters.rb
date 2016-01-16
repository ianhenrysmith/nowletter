class AddSendCountToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :send_count, :integer, default: 0
  end
end
