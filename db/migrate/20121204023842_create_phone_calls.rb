class CreatePhoneCalls < ActiveRecord::Migration
  def change
    create_table :phone_calls do |t|
      t.integer :direction
      t.integer :duration
      t.integer :response_time

      t.timestamps
    end
  end
end
