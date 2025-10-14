require "test_helper"

class ComplianceAreaTest < ActiveSupport::TestCase
  test "should have a name and code" do
    area = ComplianceArea.create!(
      name: "Data Minimization",
      code: "data_minimization",
      description: "Ensures only necessary data is collected"
    )

    assert_equal "Data Minimization", area.name
    assert_equal "data_minimization", area.code
  end

  test "should require name" do
    area = ComplianceArea.new(code: "test")

    assert_not area.valid?
    assert area.errors[:name].any?
  end

  test "should require code" do
    area = ComplianceArea.new(name: "Test Area")

    assert_not area.valid?
    assert area.errors[:code].any?
  end

  test "should require unique code" do
    area1 = ComplianceArea.create!(name: "Area 1", code: "unique_code")
    area2 = ComplianceArea.new(name: "Area 2", code: "unique_code")

    assert_not area2.valid?
    assert area2.errors[:code].any?
  end

  test "should have many compliance area scores" do
    area = compliance_areas(:lawfulness)

    assert_respond_to area, :compliance_area_scores
  end
end
