class AddPublicFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_flag, :boolean, default: false

  end
end
