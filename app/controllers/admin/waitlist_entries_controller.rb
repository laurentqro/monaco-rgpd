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
    # Use ActiveRecord with Arel for safe SQL generation
    WaitlistEntry
      .select(Arel.sql("jsonb_array_elements_text(features_needed) as feature"), Arel.sql("COUNT(*) as count"))
      .group(Arel.sql("jsonb_array_elements_text(features_needed)"))
      .order(Arel.sql("count DESC"))
      .pluck(Arel.sql("jsonb_array_elements_text(features_needed)"), Arel.sql("COUNT(*)"))
      .to_h
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
