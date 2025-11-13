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
    # Count entries per feature
    counts = Hash.new(0)

    WaitlistEntry.find_each do |entry|
      entry.features_needed.each do |feature|
        counts[feature] += 1
      end
    end

    counts
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
