class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :phone_number
      t.string :contact_name
      t.string :contact_phone_number
      t.string :system_number

      t.timestamps
    end
  end
end
