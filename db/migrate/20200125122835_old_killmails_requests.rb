class OldKillmailsRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :old_killmails_requests do |t|
      t.string :url, index: true
      t.string :result

      t.timestamps
    end
  end
end
