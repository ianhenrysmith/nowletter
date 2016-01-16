class AddSentAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :sent_at, :datetime
  end
end
