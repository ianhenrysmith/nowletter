class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.belongs_to :newsletter, index: true

      t.timestamps null: false
    end
  end
end
