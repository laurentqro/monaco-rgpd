class AllowNullRespondentIdInResponses < ActiveRecord::Migration[8.0]
  def change
    change_column_null :responses, :respondent_id, true
  end
end
