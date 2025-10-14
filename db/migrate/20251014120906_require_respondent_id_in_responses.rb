class RequireRespondentIdInResponses < ActiveRecord::Migration[8.0]
  def change
    change_column_null :responses, :respondent_id, false
  end
end
