class OldRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :old_requests do |t|
      t.string :url, index: true
      t.string :type
      t.string :result

      t.timestamps
    end
  end
end
