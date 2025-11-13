class Admin::WaitlistEntriesController < Admin::BaseController
  def index
    # Group by feature and count
    feature_counts = calculate_feature_counts

    @entries = WaitlistEntry.includes(:response)
                            .order(created_at: :desc)
                            .limit(100)

    render inertia: "admin/WaitlistEntries/Index", props: {
      entries: @entries.map { |e| serialize_entry(e) },
      feature_counts: feature_counts
    }
  end

  private

  def calculate_feature_counts
    # Use PostgreSQL JSONB functions for efficient aggregation
    result = ActiveRecord::Base.connection.execute(<<-SQL.squish)
      SELECT jsonb_array_elements_text(features_needed) as feature, COUNT(*) as count
      FROM waitlist_entries
      GROUP BY feature
      ORDER BY count DESC
    SQL

    result.to_h { |row| [ row["feature"], row["count"].to_i ] }
  end

  def serialize_entry(entry)
    {
      id: entry.id,
      email: entry.email,
      features_needed: entry.features_needed,
      created_at: entry.created_at.iso8601,
      notified: entry.notified
    }
  end
end
