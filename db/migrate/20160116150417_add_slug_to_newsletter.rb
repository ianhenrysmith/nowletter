class AddSlugToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :slug, :string
  end
end
