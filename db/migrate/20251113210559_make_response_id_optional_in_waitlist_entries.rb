class MakeResponseIdOptionalInWaitlistEntries < ActiveRecord::Migration[8.1]
  def change
    change_column_null :waitlist_entries, :response_id, true
  end
end
