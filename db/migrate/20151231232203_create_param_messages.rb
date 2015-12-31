class CreateParamMessages < ActiveRecord::Migration
  def change
    create_table :param_messages do |t|
      t.string "body"
    end
  end
end
