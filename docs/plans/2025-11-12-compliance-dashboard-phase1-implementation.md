# Compliance Dashboard Phase 1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform dashboard from passive assessment display into active compliance command center with actionable inbox, quick actions, and enhanced health snapshot.

**Architecture:** Add ActionItem model to track assessment-driven recommendations, create ActionItemGenerator service to analyze assessments and generate prioritized tasks, enhance frontend with three new components (ActionItemsInbox, QuickActionsPanel, enhanced ComplianceHealthSnapshot).

**Tech Stack:** Rails 8, PostgreSQL, Svelte 5 (runes), shadcn-svelte, Inertia.js

---

## Task 1: Create ActionItem Model

**Files:**
- Create: `db/migrate/YYYYMMDDHHMMSS_create_action_items.rb`
- Create: `app/models/action_item.rb`
- Create: `test/models/action_item_test.rb`

### Step 1: Write the failing model test

```ruby
# test/models/action_item_test.rb
require "test_helper"

class ActionItemTest < ActiveSupport::TestCase
  test "valid action item" do
    action_item = ActionItem.new(
      account: accounts(:company),
      actionable: compliance_assessments(:assessment_one),
      source: :assessment,
      priority: :medium,
      status: :pending,
      action_type: :update_treatment,
      title: "Add encryption to Customer Data treatment",
      description: "Implement encryption for customer personal data",
      action_params: { treatment_id: 1 },
      due_at: 7.days.from_now,
      impact_score: 15
    )
    assert action_item.valid?
  end

  test "requires account" do
    action_item = ActionItem.new(
      actionable: compliance_assessments(:assessment_one),
      source: :assessment,
      title: "Test"
    )
    assert_not action_item.valid?
    assert_includes action_item.errors[:account], "must exist"
  end

  test "requires title" do
    action_item = ActionItem.new(
      account: accounts(:company),
      actionable: compliance_assessments(:assessment_one),
      source: :assessment
    )
    assert_not action_item.valid?
    assert_includes action_item.errors[:title], "can't be blank"
  end

  test "requires source" do
    action_item = ActionItem.new(
      account: accounts(:company),
      actionable: compliance_assessments(:assessment_one),
      title: "Test"
    )
    assert_not action_item.valid?
    assert_includes action_item.errors[:source], "can't be blank"
  end

  test "belongs to actionable polymorphically" do
    action_item = action_items(:recommendation_one)
    assert_instance_of ComplianceAssessment, action_item.actionable
  end

  test "pending scope returns only pending items" do
    ActionItem.create!(
      account: accounts(:company),
      actionable: compliance_assessments(:assessment_one),
      source: :assessment,
      priority: :high,
      status: :pending,
      action_type: :generate_document,
      title: "Pending item"
    )

    ActionItem.create!(
      account: accounts(:company),
      actionable: compliance_assessments(:assessment_one),
      source: :assessment,
      priority: :low,
      status: :completed,
      action_type: :generate_document,
      title: "Completed item"
    )

    pending_items = ActionItem.pending
    assert pending_items.all? { |item| item.status == "pending" }
  end

  test "by_priority scope orders by priority descending" do
    low_item = ActionItem.create!(
      account: accounts(:company),
      actionable: compliance_assessments(:assessment_one),
      source: :assessment,
      priority: :low,
      status: :pending,
      action_type: :generate_document,
      title: "Low priority"
    )

    critical_item = ActionItem.create!(
      account: accounts(:company),
      actionable: compliance_assessments(:assessment_one),
      source: :assessment,
      priority: :critical,
      status: :pending,
      action_type: :generate_document,
      title: "Critical priority"
    )

    items = ActionItem.by_priority.to_a
    assert_equal critical_item.id, items.first.id
    assert_equal low_item.id, items.last.id
  end
end
```

### Step 2: Run test to verify it fails

Run: `bin/rails test test/models/action_item_test.rb`

Expected: FAIL with "uninitialized constant ActionItem"

### Step 3: Create migration

```ruby
# db/migrate/YYYYMMDDHHMMSS_create_action_items.rb
class CreateActionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :action_items do |t|
      t.references :account, null: false, foreign_key: true
      t.references :actionable, polymorphic: true, null: false

      t.integer :source, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.integer :action_type, null: false, default: 0

      t.string :title, null: false
      t.text :description
      t.jsonb :action_params, default: {}

      t.datetime :due_at
      t.integer :impact_score
      t.datetime :snoozed_until

      t.timestamps
    end

    add_index :action_items, [:account_id, :status]
    add_index :action_items, [:account_id, :priority]
    add_index :action_items, :actionable_type
  end
end
```

### Step 4: Create ActionItem model

```ruby
# app/models/action_item.rb
class ActionItem < ApplicationRecord
  belongs_to :account
  belongs_to :actionable, polymorphic: true

  enum source: { assessment: 0, regulatory_deadline: 1, system_recommendation: 2 }
  enum priority: { low: 0, medium: 1, high: 2, critical: 3 }
  enum status: { pending: 0, in_progress: 1, completed: 2, dismissed: 3 }
  enum action_type: {
    update_treatment: 0,
    generate_document: 1,
    complete_wizard: 2,
    respond_to_sar: 3,
    notify_breach: 4
  }

  validates :title, presence: true
  validates :source, presence: true

  scope :for_account, ->(account) { where(account: account) }
  scope :pending, -> { where(status: :pending) }
  scope :by_priority, -> { order(priority: :desc) }
  scope :active, -> { where(status: [:pending, :in_progress]) }
end
```

### Step 5: Add fixture

```yaml
# test/fixtures/action_items.yml
recommendation_one:
  account: company
  actionable: assessment_one (ComplianceAssessment)
  source: assessment
  priority: high
  status: pending
  action_type: update_treatment
  title: "Add encryption to Customer Data treatment"
  description: "Implement encryption for customer personal data"
  action_params: { "treatment_id": 1 }
  due_at: <%= 7.days.from_now %>
  impact_score: 15
```

### Step 6: Run migration and test

Run:
```bash
bin/rails db:migrate
bin/rails test test/models/action_item_test.rb
```

Expected: All tests PASS

### Step 7: Commit

```bash
git add db/migrate db/schema.rb app/models/action_item.rb test/models/action_item_test.rb test/fixtures/action_items.yml
git commit -m "feat: add ActionItem model for compliance recommendations"
```

---

## Task 2: Create ActionItemGenerator Service

**Files:**
- Create: `app/services/action_item_generator.rb`
- Create: `test/services/action_item_generator_test.rb`

### Step 1: Write the failing service test

```ruby
# test/services/action_item_generator_test.rb
require "test_helper"

class ActionItemGeneratorTest < ActiveSupport::TestCase
  test "generates action items from compliance assessment" do
    assessment = compliance_assessments(:assessment_one)
    # Create area scores with varying percentages
    area1 = compliance_areas(:data_security)
    area2 = compliance_areas(:legal_basis)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area1,
      score: 45,
      max_score: 100
    )

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area2,
      score: 85,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)

    assert_difference "ActionItem.count", 1 do
      generator.generate
    end

    action_item = ActionItem.last
    assert_equal assessment.account, action_item.account
    assert_equal assessment, action_item.actionable
    assert_equal "assessment", action_item.source
    assert action_item.title.present?
  end

  test "generates high priority items for scores below 60%" do
    assessment = compliance_assessments(:assessment_one)
    area = compliance_areas(:data_security)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 30,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)
    generator.generate

    action_item = ActionItem.last
    assert_equal "high", action_item.priority
  end

  test "generates medium priority items for scores 60-79%" do
    assessment = compliance_assessments(:assessment_one)
    area = compliance_areas(:data_security)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 70,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)
    generator.generate

    action_item = ActionItem.last
    assert_equal "medium", action_item.priority
  end

  test "does not generate items for scores 80% and above" do
    assessment = compliance_assessments(:assessment_one)
    area = compliance_areas(:data_security)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 85,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)

    assert_no_difference "ActionItem.count" do
      generator.generate
    end
  end

  test "does not duplicate action items on multiple calls" do
    assessment = compliance_assessments(:assessment_one)
    area = compliance_areas(:data_security)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 50,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)

    generator.generate
    first_count = ActionItem.count

    generator.generate
    assert_equal first_count, ActionItem.count
  end
end
```

### Step 2: Run test to verify it fails

Run: `bin/rails test test/services/action_item_generator_test.rb`

Expected: FAIL with "uninitialized constant ActionItemGenerator"

### Step 3: Create ActionItemGenerator service

```ruby
# app/services/action_item_generator.rb
class ActionItemGenerator
  def initialize(compliance_assessment)
    @assessment = compliance_assessment
    @account = compliance_assessment.account
  end

  def generate
    return if already_generated?

    @assessment.compliance_area_scores.each do |area_score|
      next if area_score.percentage >= 80

      create_action_item_for_area(area_score)
    end
  end

  private

  def already_generated?
    ActionItem.exists?(
      actionable: @assessment,
      account: @account,
      source: :assessment
    )
  end

  def create_action_item_for_area(area_score)
    ActionItem.create!(
      account: @account,
      actionable: @assessment,
      source: :assessment,
      priority: determine_priority(area_score.percentage),
      status: :pending,
      action_type: determine_action_type(area_score.compliance_area),
      title: generate_title(area_score.compliance_area, area_score.percentage),
      description: generate_description(area_score.compliance_area, area_score.percentage),
      impact_score: calculate_impact_score(area_score.percentage),
      action_params: { compliance_area_id: area_score.compliance_area.id }
    )
  end

  def determine_priority(percentage)
    case percentage
    when 0...60 then :high
    when 60...80 then :medium
    else :low
    end
  end

  def determine_action_type(compliance_area)
    # For now, default to update_treatment
    # This can be enhanced in future phases
    :update_treatment
  end

  def generate_title(compliance_area, percentage)
    if percentage < 60
      "Améliorer la conformité : #{compliance_area.name}"
    else
      "Optimiser : #{compliance_area.name}"
    end
  end

  def generate_description(compliance_area, percentage)
    score_gap = 100 - percentage
    "Votre score dans le domaine '#{compliance_area.name}' est de #{percentage.round}%. " \
    "Une amélioration de #{score_gap.round}% est nécessaire pour atteindre la conformité optimale."
  end

  def calculate_impact_score(percentage)
    # Impact score is roughly how much improvement is needed
    (100 - percentage).round
  end
end
```

### Step 4: Run test to verify it passes

Run: `bin/rails test test/services/action_item_generator_test.rb`

Expected: All tests PASS

### Step 5: Commit

```bash
git add app/services/action_item_generator.rb test/services/action_item_generator_test.rb
git commit -m "feat: add ActionItemGenerator service to create recommendations from assessments"
```

---

## Task 3: Integrate ActionItemGenerator with ComplianceAssessment

**Files:**
- Modify: `app/models/compliance_assessment.rb`
- Modify: `app/services/compliance_scorer.rb`
- Create: `test/integration/action_item_generation_test.rb`

### Step 1: Write integration test

```ruby
# test/integration/action_item_generation_test.rb
require "test_helper"

class ActionItemGenerationTest < ActiveSupport::TestCase
  test "action items are generated when compliance assessment is created" do
    response = responses(:response_one)

    # Create answers with varying compliance levels
    # Assuming questions exist in fixtures with compliance_area associations

    assert_difference "ActionItem.count" do
      ComplianceScorer.new(response).score
    end
  end
end
```

### Step 2: Run test to verify it fails

Run: `bin/rails test test/integration/action_item_generation_test.rb`

Expected: FAIL - action items not generated

### Step 3: Update ComplianceScorer to generate action items

```ruby
# app/services/compliance_scorer.rb
# Add after creating the assessment

class ComplianceScorer
  # ... existing code ...

  def score
    # ... existing code to create assessment ...

    # Generate action items from the assessment
    ActionItemGenerator.new(assessment).generate

    assessment
  end
end
```

### Step 4: Add has_many association to ComplianceAssessment

```ruby
# app/models/compliance_assessment.rb
class ComplianceAssessment < ApplicationRecord
  belongs_to :response
  belongs_to :account
  has_many :compliance_area_scores, dependent: :destroy
  has_many :compliance_areas, through: :compliance_area_scores
  has_many :action_items, as: :actionable, dependent: :destroy  # ADD THIS LINE

  # ... rest of the model ...
end
```

### Step 5: Run tests

Run: `bin/rails test`

Expected: All tests PASS

### Step 6: Commit

```bash
git add app/services/compliance_scorer.rb app/models/compliance_assessment.rb test/integration/action_item_generation_test.rb
git commit -m "feat: auto-generate action items when compliance assessment is created"
```

---

## Task 4: Create ActionItemsController

**Files:**
- Create: `app/controllers/action_items_controller.rb`
- Create: `test/controllers/action_items_controller_test.rb`
- Modify: `config/routes.rb`

### Step 1: Write controller tests

```ruby
# test/controllers/action_items_controller_test.rb
require "test_helper"

class ActionItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @account = @user.account
    sign_in(@user)

    @action_item = ActionItem.create!(
      account: @account,
      actionable: compliance_assessments(:assessment_one),
      source: :assessment,
      priority: :high,
      status: :pending,
      action_type: :update_treatment,
      title: "Test action item"
    )
  end

  test "update sets action item to completed" do
    patch action_item_path(@action_item), params: {
      action_item: { status: "completed" }
    }

    assert_redirected_to dashboard_path
    @action_item.reload
    assert_equal "completed", @action_item.status
  end

  test "update can dismiss action item" do
    patch action_item_path(@action_item), params: {
      action_item: { status: "dismissed" }
    }

    @action_item.reload
    assert_equal "dismissed", @action_item.status
  end

  test "update can snooze action item" do
    snooze_until = 3.days.from_now
    patch action_item_path(@action_item), params: {
      action_item: { snoozed_until: snooze_until }
    }

    @action_item.reload
    assert_in_delta snooze_until.to_i, @action_item.snoozed_until.to_i, 2
  end

  test "cannot update another account's action item" do
    other_account = accounts(:other_company)
    other_item = ActionItem.create!(
      account: other_account,
      actionable: compliance_assessments(:assessment_one),
      source: :assessment,
      priority: :medium,
      status: :pending,
      action_type: :generate_document,
      title: "Other account item"
    )

    patch action_item_path(other_item), params: {
      action_item: { status: "completed" }
    }

    assert_response :not_found
  end

  test "requires authentication" do
    sign_out(@user)

    patch action_item_path(@action_item), params: {
      action_item: { status: "completed" }
    }

    assert_redirected_to sign_in_path
  end
end
```

### Step 2: Run test to verify it fails

Run: `bin/rails test test/controllers/action_items_controller_test.rb`

Expected: FAIL with "No route matches"

### Step 3: Add route

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ... existing routes ...

  resources :action_items, only: [:update]

  # ... rest of routes ...
end
```

### Step 4: Create controller

```ruby
# app/controllers/action_items_controller.rb
class ActionItemsController < ApplicationController
  before_action :set_action_item

  def update
    if @action_item.update(action_item_params)
      redirect_to dashboard_path, notice: "Action mise à jour."
    else
      redirect_to dashboard_path, alert: "Impossible de mettre à jour l'action."
    end
  end

  private

  def set_action_item
    @action_item = Current.account.action_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  end

  def action_item_params
    params.require(:action_item).permit(:status, :snoozed_until)
  end
end
```

### Step 5: Add association to Account model

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  # ... existing associations ...
  has_many :action_items, dependent: :destroy  # ADD THIS LINE
  # ... rest of model ...
end
```

### Step 6: Run tests

Run: `bin/rails test test/controllers/action_items_controller_test.rb`

Expected: All tests PASS

### Step 7: Commit

```bash
git add app/controllers/action_items_controller.rb test/controllers/action_items_controller_test.rb config/routes.rb app/models/account.rb
git commit -m "feat: add ActionItemsController for updating action items"
```

---

## Task 5: Update DashboardController to Pass Action Items

**Files:**
- Modify: `app/controllers/dashboard_controller.rb`
- Modify: `test/controllers/dashboard_controller_test.rb`

### Step 1: Write failing test for action items in dashboard props

```ruby
# test/controllers/dashboard_controller_test.rb
# Add this test to existing file

test "dashboard includes action items" do
  user = users(:user_one)
  sign_in(user)

  # Create action items for this account
  ActionItem.create!(
    account: user.account,
    actionable: compliance_assessments(:assessment_one),
    source: :assessment,
    priority: :high,
    status: :pending,
    action_type: :update_treatment,
    title: "High priority item"
  )

  ActionItem.create!(
    account: user.account,
    actionable: compliance_assessments(:assessment_one),
    source: :assessment,
    priority: :low,
    status: :pending,
    action_type: :generate_document,
    title: "Low priority item"
  )

  get dashboard_path

  assert_response :success
  # Inertia passes props as JSON
  props = JSON.parse(response.headers["X-Inertia"]) rescue controller.instance_variable_get(:@_inertia_shared_props)

  assert props["action_items"].present?
  assert_equal 2, props["action_items"].length
  # Should be ordered by priority desc
  assert_equal "High priority item", props["action_items"].first["title"]
end
```

### Step 2: Run test to verify it fails

Run: `bin/rails test test/controllers/dashboard_controller_test.rb`

Expected: FAIL - action_items not present in props

### Step 3: Update DashboardController

```ruby
# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def show
    latest_response = Current.account.responses
      .includes(:compliance_assessment)
      .completed
      .order(created_at: :desc)
      .first

    published_questionnaire = Questionnaire.published.first

    render inertia: "Dashboard/Show", props: {
      latest_assessment: latest_response&.compliance_assessment ? assessment_props(latest_response.compliance_assessment) : nil,
      latest_response_id: latest_response&.id,
      responses: Current.account.responses.order(created_at: :desc).limit(5).map { |r| response_summary_props(r) },
      questionnaire_id: published_questionnaire&.id,
      action_items: action_items_props  # ADD THIS LINE
    }
  end

  private

  def assessment_props(assessment)
    {
      overall_score: assessment.overall_score.round(1),
      max_possible_score: assessment.max_possible_score,
      risk_level: assessment.risk_level,
      created_at: assessment.created_at,
      compliance_area_scores: assessment.compliance_area_scores.includes(:compliance_area).map do |cas|
        {
          area_name: cas.compliance_area.name,
          area_code: cas.compliance_area.code,
          score: cas.score.round(1),
          max_score: cas.max_score,
          percentage: cas.percentage
        }
      end
    }
  end

  def response_summary_props(response)
    {
      id: response.id,
      created_at: response.created_at,
      completed_at: response.completed_at,
      status: response.status
    }
  end

  # ADD THIS METHOD
  def action_items_props
    Current.account.action_items
      .active
      .by_priority
      .includes(:actionable)
      .map do |item|
        {
          id: item.id,
          title: item.title,
          description: item.description,
          priority: item.priority,
          status: item.status,
          action_type: item.action_type,
          due_at: item.due_at,
          impact_score: item.impact_score,
          created_at: item.created_at
        }
      end
  end
end
```

### Step 4: Run test to verify it passes

Run: `bin/rails test test/controllers/dashboard_controller_test.rb`

Expected: All tests PASS

### Step 5: Commit

```bash
git add app/controllers/dashboard_controller.rb test/controllers/dashboard_controller_test.rb
git commit -m "feat: pass action items to dashboard frontend"
```

---

## Task 6: Create ActionItemsInbox Svelte Component

**Files:**
- Create: `app/frontend/components/dashboard/ActionItemsInbox.svelte`
- Create: `app/frontend/components/dashboard/ActionItem.svelte`
- Modify: `app/frontend/pages/Dashboard/Show.svelte`

### Step 1: Create ActionItem component

```svelte
<!-- app/frontend/components/dashboard/ActionItem.svelte -->
<script>
  import { Button } from '$lib/components/ui/button';
  import { Badge } from '$lib/components/ui/badge';
  import { router } from '@inertiajs/svelte';

  let { item } = $props();

  const priorityVariants = {
    critical: 'destructive',
    high: 'destructive',
    medium: 'secondary',
    low: 'outline'
  };

  const priorityLabels = {
    critical: 'Critique',
    high: 'Haute',
    medium: 'Moyenne',
    low: 'Basse'
  };

  function markAsCompleted() {
    router.patch(`/action_items/${item.id}`, {
      action_item: { status: 'completed' }
    });
  }

  function dismiss() {
    router.patch(`/action_items/${item.id}`, {
      action_item: { status: 'dismissed' }
    });
  }
</script>

<div class="flex items-start justify-between p-4 border rounded-lg bg-white">
  <div class="flex-1">
    <div class="flex items-center gap-2 mb-2">
      <Badge variant={priorityVariants[item.priority]}>
        {priorityLabels[item.priority]}
      </Badge>
      {#if item.impact_score}
        <span class="text-sm text-gray-500">Impact: +{item.impact_score}%</span>
      {/if}
    </div>

    <h3 class="font-semibold mb-1">{item.title}</h3>
    {#if item.description}
      <p class="text-sm text-gray-600 mb-2">{item.description}</p>
    {/if}

    {#if item.due_at}
      <p class="text-xs text-gray-500">
        Échéance: {new Date(item.due_at).toLocaleDateString('fr-FR')}
      </p>
    {/if}
  </div>

  <div class="flex gap-2 ml-4">
    <Button size="sm" onclick={markAsCompleted}>
      Terminé
    </Button>
    <Button size="sm" variant="ghost" onclick={dismiss}>
      Ignorer
    </Button>
  </div>
</div>
```

### Step 2: Create ActionItemsInbox component

```svelte
<!-- app/frontend/components/dashboard/ActionItemsInbox.svelte -->
<script>
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card';
  import ActionItem from './ActionItem.svelte';

  let { actionItems } = $props();

  const groupedItems = $derived(() => {
    const groups = {
      critical: [],
      high: [],
      medium: [],
      low: []
    };

    actionItems.forEach(item => {
      groups[item.priority].push(item);
    });

    return groups;
  });

  const priorityLabels = {
    critical: 'Critique',
    high: 'Haute priorité',
    medium: 'Priorité moyenne',
    low: 'Priorité basse'
  };
</script>

<Card class="mb-8">
  <CardHeader>
    <CardTitle>Actions à réaliser</CardTitle>
    <CardDescription>
      {actionItems.length} action{actionItems.length > 1 ? 's' : ''} recommandée{actionItems.length > 1 ? 's' : ''}
    </CardDescription>
  </CardHeader>
  <CardContent>
    {#if actionItems.length === 0}
      <p class="text-center text-gray-500 py-8">
        Aucune action en attente. Excellent travail ! 🎉
      </p>
    {:else}
      <div class="space-y-6">
        {#each Object.entries(groupedItems()) as [priority, items]}
          {#if items.length > 0}
            <div>
              <h3 class="text-sm font-semibold text-gray-700 mb-3">
                {priorityLabels[priority]} ({items.length})
              </h3>
              <div class="space-y-3">
                {#each items as item (item.id)}
                  <ActionItem {item} />
                {/each}
              </div>
            </div>
          {/if}
        {/each}
      </div>
    {/if}
  </CardContent>
</Card>
```

### Step 3: Integrate into Dashboard

```svelte
<!-- app/frontend/pages/Dashboard/Show.svelte -->
<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import { Button } from '$lib/components/ui/button';
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Badge } from '$lib/components/ui/badge';
  import ComplianceScoreCard from '../../components/ComplianceScoreCard.svelte';
  import ActionItemsInbox from '../../components/dashboard/ActionItemsInbox.svelte'; // ADD
  import { router, page } from '@inertiajs/svelte';
  import { toast } from 'svelte-sonner';

  let { latest_assessment, latest_response_id, responses, questionnaire_id, action_items } = $props(); // ADD action_items

  // ... rest of existing code ...
</script>

<AppLayout>
<div class="min-h-screen bg-gray-50">
  <div class="max-w-7xl mx-auto px-4 py-8">
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-3xl font-bold">Tableau de bord de conformité</h1>
      <div class="flex items-center gap-4">
        {#if latest_assessment && questionnaire_id}
          <Button
            onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
          >
            <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Nouvelle évaluation
          </Button>
        {/if}
        <Button
          variant="outline"
          onclick={() => router.delete('/session')}
        >
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Déconnexion
        </Button>
      </div>
    </div>

    <!-- ADD ACTION ITEMS INBOX -->
    {#if latest_assessment}
      <ActionItemsInbox actionItems={action_items || []} />
    {/if}

    {#if latest_assessment}
      <ComplianceScoreCard assessment={latest_assessment} responseId={latest_response_id} />
    {:else}
      <!-- ... existing welcome card ... -->
    {/if}
  </div>
</div>
</AppLayout>
```

### Step 4: Manually test in browser

Run: `bin/dev`
Navigate to dashboard and verify action items appear

### Step 5: Commit

```bash
git add app/frontend/components/dashboard/ActionItemsInbox.svelte app/frontend/components/dashboard/ActionItem.svelte app/frontend/pages/Dashboard/Show.svelte
git commit -m "feat: add ActionItemsInbox component to dashboard"
```

---

## Task 7: Create QuickActionsPanel Component

**Files:**
- Create: `app/frontend/components/dashboard/QuickActionsPanel.svelte`
- Modify: `app/frontend/pages/Dashboard/Show.svelte`

### Step 1: Create QuickActionsPanel component

```svelte
<!-- app/frontend/components/dashboard/QuickActionsPanel.svelte -->
<script>
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Button } from '$lib/components/ui/button';
  import { Badge } from '$lib/components/ui/badge';
  import { router } from '@inertiajs/svelte';

  let { questionnaireId, latestAssessment, processingActivitiesCount = 0 } = $props();

  function startNewAssessment() {
    router.post(`/questionnaires/${questionnaireId}/responses`);
  }

  function navigateToDocuments() {
    router.visit('/documents');
  }

  function navigateToTreatments() {
    router.visit('/processing_activities');
  }
</script>

<Card class="mb-8">
  <CardHeader>
    <CardTitle>Actions rapides</CardTitle>
  </CardHeader>
  <CardContent>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <!-- Assessments -->
      <div class="border rounded-lg p-4">
        <h3 class="font-semibold mb-2 flex items-center">
          <svg class="w-5 h-5 mr-2 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
          Évaluations
        </h3>
        {#if latestAssessment}
          <p class="text-sm text-gray-600 mb-3">
            Dernière évaluation: {new Date(latestAssessment.created_at).toLocaleDateString('fr-FR')}
          </p>
          <Badge variant="secondary" class="mb-3">
            Score actuel: {latestAssessment.overall_score.toFixed(0)}%
          </Badge>
        {/if}
        <Button onclick={startNewAssessment} class="w-full" disabled={!questionnaireId}>
          Nouvelle évaluation
        </Button>
      </div>

      <!-- Documents -->
      <div class="border rounded-lg p-4">
        <h3 class="font-semibold mb-2 flex items-center">
          <svg class="w-5 h-5 mr-2 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          Documents
        </h3>
        <p class="text-sm text-gray-600 mb-3">
          Générez vos documents de conformité
        </p>
        <Button onclick={navigateToDocuments} variant="outline" class="w-full">
          Gérer les documents
        </Button>
      </div>

      <!-- Processing Activities -->
      <div class="border rounded-lg p-4">
        <h3 class="font-semibold mb-2 flex items-center">
          <svg class="w-5 h-5 mr-2 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
          </svg>
          Registre des traitements
        </h3>
        <p class="text-sm text-gray-600 mb-3">
          {processingActivitiesCount} traitement{processingActivitiesCount > 1 ? 's' : ''} actif{processingActivitiesCount > 1 ? 's' : ''}
        </p>
        <Button onclick={navigateToTreatments} variant="outline" class="w-full">
          Voir les traitements
        </Button>
      </div>
    </div>
  </CardContent>
</Card>
```

### Step 2: Update DashboardController to pass processing activities count

```ruby
# app/controllers/dashboard_controller.rb
def show
  # ... existing code ...

  render inertia: "Dashboard/Show", props: {
    latest_assessment: latest_response&.compliance_assessment ? assessment_props(latest_response.compliance_assessment) : nil,
    latest_response_id: latest_response&.id,
    responses: Current.account.responses.order(created_at: :desc).limit(5).map { |r| response_summary_props(r) },
    questionnaire_id: published_questionnaire&.id,
    action_items: action_items_props,
    processing_activities_count: Current.account.processing_activities.count  # ADD THIS
  }
end
```

### Step 3: Integrate into Dashboard

```svelte
<!-- app/frontend/pages/Dashboard/Show.svelte -->
<script>
  // ... existing imports ...
  import QuickActionsPanel from '../../components/dashboard/QuickActionsPanel.svelte'; // ADD

  let {
    latest_assessment,
    latest_response_id,
    responses,
    questionnaire_id,
    action_items,
    processing_activities_count  // ADD
  } = $props();

  // ... rest of code ...
</script>

<AppLayout>
<div class="min-h-screen bg-gray-50">
  <div class="max-w-7xl mx-auto px-4 py-8">
    <!-- ... header ... -->

    {#if latest_assessment}
      <ActionItemsInbox actionItems={action_items || []} />

      <!-- ADD QUICK ACTIONS PANEL -->
      <QuickActionsPanel
        questionnaireId={questionnaire_id}
        latestAssessment={latest_assessment}
        processingActivitiesCount={processing_activities_count || 0}
      />

      <ComplianceScoreCard assessment={latest_assessment} responseId={latest_response_id} />
    {:else}
      <!-- ... welcome card ... -->
    {/if}
  </div>
</div>
</AppLayout>
```

### Step 4: Manually test in browser

Run: `bin/dev`
Verify quick actions panel appears and buttons work

### Step 5: Commit

```bash
git add app/frontend/components/dashboard/QuickActionsPanel.svelte app/frontend/pages/Dashboard/Show.svelte app/controllers/dashboard_controller.rb
git commit -m "feat: add QuickActionsPanel component to dashboard"
```

---

## Task 8: Enhance ComplianceHealthSnapshot with Drill-Down

**Files:**
- Create: `app/frontend/components/dashboard/ComplianceHealthSnapshot.svelte`
- Create: `app/frontend/components/dashboard/ComplianceAreaCard.svelte`
- Modify: `app/frontend/pages/Dashboard/Show.svelte`
- Modify: `app/controllers/dashboard_controller.rb`

### Step 1: Update DashboardController to pass detailed area data

```ruby
# app/controllers/dashboard_controller.rb
# Modify assessment_props method

def assessment_props(assessment)
  {
    overall_score: assessment.overall_score.round(1),
    max_possible_score: assessment.max_possible_score,
    risk_level: assessment.risk_level,
    created_at: assessment.created_at,
    compliance_area_scores: compliance_area_scores_props(assessment)  # CHANGE THIS
  }
end

# ADD THIS METHOD
def compliance_area_scores_props(assessment)
  assessment.compliance_area_scores.includes(:compliance_area).map do |cas|
    {
      id: cas.id,
      area_name: cas.compliance_area.name,
      area_code: cas.compliance_area.code,
      score: cas.score.round(1),
      max_score: cas.max_score,
      percentage: cas.percentage,
      risk_level: determine_area_risk_level(cas.percentage)
    }
  end
end

# ADD THIS METHOD
def determine_area_risk_level(percentage)
  case percentage
  when 85..100 then "compliant"
  when 60..84 then "attention_required"
  else "non_compliant"
  end
end
```

### Step 2: Create ComplianceAreaCard component

```svelte
<!-- app/frontend/components/dashboard/ComplianceAreaCard.svelte -->
<script>
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Badge } from '$lib/components/ui/badge';

  let { areaScore, expanded = $bindable(false) } = $props();

  const riskLevelColors = {
    compliant: 'bg-green-100 border-green-300',
    attention_required: 'bg-yellow-100 border-yellow-300',
    non_compliant: 'bg-red-100 border-red-300'
  };

  const riskLevelBadges = {
    compliant: 'default',
    attention_required: 'secondary',
    non_compliant: 'destructive'
  };

  const riskLevelLabels = {
    compliant: 'Conforme',
    attention_required: 'Attention requise',
    non_compliant: 'Non conforme'
  };

  const areaIcons = {
    'legal_basis': '⚖️',
    'data_security': '🔒',
    'data_subjects_rights': '👤',
    'dpo_obligations': '📋',
    'data_transfers': '🌍',
    'breach_notification': '🚨',
    'documentation': '📄'
  };

  function toggleExpanded() {
    expanded = !expanded;
  }
</script>

<Card class="cursor-pointer hover:shadow-md transition-shadow {riskLevelColors[areaScore.risk_level]}" onclick={toggleExpanded}>
  <CardHeader>
    <div class="flex items-start justify-between">
      <div class="flex items-center gap-2">
        <span class="text-2xl">{areaIcons[areaScore.area_code] || '📊'}</span>
        <div>
          <CardTitle class="text-lg">{areaScore.area_name}</CardTitle>
        </div>
      </div>
      <div class="text-right">
        <div class="text-3xl font-bold mb-1">{areaScore.percentage.toFixed(0)}%</div>
        <Badge variant={riskLevelBadges[areaScore.risk_level]}>
          {riskLevelLabels[areaScore.risk_level]}
        </Badge>
      </div>
    </div>
  </CardHeader>

  {#if expanded}
    <CardContent>
      <div class="border-t pt-4">
        <p class="text-sm text-gray-600 mb-3">
          Score: {areaScore.score.toFixed(1)} / {areaScore.max_score}
        </p>

        {#if areaScore.percentage < 80}
          <div class="bg-blue-50 border border-blue-200 rounded p-3">
            <p class="text-sm font-semibold mb-1">💡 Amélioration recommandée</p>
            <p class="text-sm text-gray-700">
              {#if areaScore.percentage < 60}
                Ce domaine nécessite une attention prioritaire. Consultez les actions recommandées ci-dessus.
              {:else}
                Quelques optimisations permettraient d'atteindre la conformité optimale.
              {/if}
            </p>
          </div>
        {:else}
          <div class="bg-green-50 border border-green-200 rounded p-3">
            <p class="text-sm font-semibold mb-1">✅ Excellent travail!</p>
            <p class="text-sm text-gray-700">
              Vous êtes conforme dans ce domaine. Continuez à maintenir ces bonnes pratiques.
            </p>
          </div>
        {/if}
      </div>
    </CardContent>
  {/if}
</Card>
```

### Step 3: Create ComplianceHealthSnapshot component

```svelte
<!-- app/frontend/components/dashboard/ComplianceHealthSnapshot.svelte -->
<script>
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card';
  import ComplianceAreaCard from './ComplianceAreaCard.svelte';

  let { assessment } = $props();

  let expandedAreas = $state({});
</script>

<Card class="mb-8">
  <CardHeader>
    <CardTitle>État de conformité par domaine</CardTitle>
    <CardDescription>
      Cliquez sur un domaine pour voir les détails
    </CardDescription>
  </CardHeader>
  <CardContent>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each assessment.compliance_area_scores as areaScore (areaScore.id)}
        <ComplianceAreaCard
          {areaScore}
          bind:expanded={expandedAreas[areaScore.id]}
        />
      {/each}
    </div>
  </CardContent>
</Card>
```

### Step 4: Integrate into Dashboard

```svelte
<!-- app/frontend/pages/Dashboard/Show.svelte -->
<script>
  // ... existing imports ...
  import ComplianceHealthSnapshot from '../../components/dashboard/ComplianceHealthSnapshot.svelte'; // ADD

  // ... rest of code ...
</script>

<AppLayout>
<div class="min-h-screen bg-gray-50">
  <div class="max-w-7xl mx-auto px-4 py-8">
    <!-- ... header ... -->

    {#if latest_assessment}
      <ActionItemsInbox actionItems={action_items || []} />

      <QuickActionsPanel
        questionnaireId={questionnaire_id}
        latestAssessment={latest_assessment}
        processingActivitiesCount={processing_activities_count || 0}
      />

      <ComplianceScoreCard assessment={latest_assessment} responseId={latest_response_id} />

      <!-- ADD COMPLIANCE HEALTH SNAPSHOT -->
      <ComplianceHealthSnapshot assessment={latest_assessment} />
    {:else}
      <!-- ... welcome card ... -->
    {/if}
  </div>
</div>
</AppLayout>
```

### Step 5: Manually test in browser

Run: `bin/dev`
Verify health snapshot appears with clickable area cards

### Step 6: Commit

```bash
git add app/frontend/components/dashboard/ComplianceHealthSnapshot.svelte app/frontend/components/dashboard/ComplianceAreaCard.svelte app/frontend/pages/Dashboard/Show.svelte app/controllers/dashboard_controller.rb
git commit -m "feat: add ComplianceHealthSnapshot with expandable area cards"
```

---

## Task 9: Add System Tests for Dashboard

**Files:**
- Create: `test/system/compliance_dashboard_test.rb`

### Step 1: Create system test

```ruby
# test/system/compliance_dashboard_test.rb
require "application_system_test_case"

class ComplianceDashboardTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
    @account = @user.account

    # Create a completed response with assessment
    @response = Response.create!(
      questionnaire: questionnaires(:published),
      account: @account,
      respondent: @user,
      status: :completed
    )

    @assessment = ComplianceAssessment.create!(
      response: @response,
      account: @account,
      overall_score: 65,
      max_possible_score: 100,
      status: :completed
    )

    # Create area scores
    ComplianceAreaScore.create!(
      compliance_assessment: @assessment,
      compliance_area: compliance_areas(:data_security),
      score: 45,
      max_score: 100
    )

    ComplianceAreaScore.create!(
      compliance_assessment: @assessment,
      compliance_area: compliance_areas(:legal_basis),
      score: 85,
      max_score: 100
    )

    # Generate action items
    ActionItemGenerator.new(@assessment).generate

    sign_in_as(@user)
  end

  test "displays action items inbox" do
    visit dashboard_path

    assert_selector "h2", text: "Actions à réaliser"
    assert_selector ".action-item", count: 1  # Only data_security is below 80%
  end

  test "can mark action item as completed" do
    visit dashboard_path

    within(".action-item") do
      click_button "Terminé"
    end

    assert_text "Action mise à jour"
    assert_no_selector ".action-item"
  end

  test "displays quick actions panel" do
    visit dashboard_path

    assert_selector "h2", text: "Actions rapides"
    assert_button "Nouvelle évaluation"
    assert_button "Gérer les documents"
    assert_button "Voir les traitements"
  end

  test "displays compliance health snapshot" do
    visit dashboard_path

    assert_selector "h2", text: "État de conformité par domaine"
    assert_text "Data Security"  # Area name
    assert_text "45%"  # Low score
    assert_text "Legal Basis"
    assert_text "85%"  # High score
  end

  test "can expand compliance area card" do
    visit dashboard_path

    # Click on Data Security card
    within("div", text: "Data Security") do
      click_on  # Click anywhere on card
    end

    # Should show expanded content
    assert_text "Amélioration recommandée"
    assert_text "attention prioritaire"
  end

  test "compliance area cards show correct risk levels" do
    visit dashboard_path

    # Data Security (45%) should be non-compliant (red)
    within("div", text: "Data Security") do
      assert_selector ".bg-red-100"
    end

    # Legal Basis (85%) should be compliant (green)
    within("div", text: "Legal Basis") do
      assert_selector ".bg-green-100"
    end
  end
end
```

### Step 2: Add CSS classes to components for test selectors

```svelte
<!-- app/frontend/components/dashboard/ActionItem.svelte -->
<!-- Add class="action-item" to the root div -->
<div class="action-item flex items-start justify-between p-4 border rounded-lg bg-white">
  <!-- ... rest of component ... -->
</div>
```

### Step 3: Skip system tests (they require Selenium setup)

```ruby
# test/system/compliance_dashboard_test.rb
# Add skip to each test
test "displays action items inbox" do
  skip "Requires Selenium setup"
  # ... test code ...
end
```

### Step 4: Commit

```bash
git add test/system/compliance_dashboard_test.rb app/frontend/components/dashboard/ActionItem.svelte
git commit -m "test: add system tests for compliance dashboard (skipped pending Selenium setup)"
```

---

## Task 10: Documentation and Final Testing

**Files:**
- Create: `docs/features/compliance-dashboard.md`

### Step 1: Create feature documentation

```markdown
<!-- docs/features/compliance-dashboard.md -->
# Compliance Dashboard

## Overview

The compliance dashboard is the central command center for monitoring and improving GDPR compliance. It provides a prioritized action items inbox, quick access to common tasks, and detailed visibility into compliance health across all areas.

## Features

### 1. Action Items Inbox

Automatically generated recommendations based on compliance assessment results:

- **Priority levels:** Critical, High, Medium, Low
- **Smart prioritization:** Items ordered by priority and impact score
- **One-click actions:** Mark as completed or dismiss
- **Impact visibility:** Shows estimated compliance score improvement

**How it works:**
- When a compliance assessment is completed, `ActionItemGenerator` analyzes area scores
- Creates action items for areas scoring below 80%
- Priority determined by score gap (< 60% = high, 60-79% = medium)

### 2. Quick Actions Panel

Fast access to common compliance tasks:

- Start new compliance assessment
- Access document generation
- View processing activities registry
- Shows contextual information (last assessment date, document status, treatment count)

### 3. Compliance Health Snapshot

Visual breakdown of compliance by area:

- **Color-coded cards:** Green (compliant), Yellow (attention required), Red (non-compliant)
- **Expandable details:** Click any card to see detailed information and recommendations
- **Risk level badges:** Instant visual feedback on compliance status
- **Responsive grid:** Adapts to screen size (1-3 columns)

## Technical Architecture

### Backend

**Models:**
- `ActionItem`: Stores recommended actions
- Associations: `account`, `actionable` (polymorphic)

**Services:**
- `ActionItemGenerator`: Creates recommendations from assessment results

**Controllers:**
- `DashboardController#show`: Passes action items and enhanced assessment data
- `ActionItemsController#update`: Handles marking items as completed/dismissed

### Frontend

**Components:**
- `ActionItemsInbox.svelte`: Groups and displays action items by priority
- `ActionItem.svelte`: Individual action item card with complete/dismiss buttons
- `QuickActionsPanel.svelte`: Grid of quick access buttons
- `ComplianceHealthSnapshot.svelte`: Grid of compliance area cards
- `ComplianceAreaCard.svelte`: Expandable area detail card

## Usage

### For Users

1. Complete a compliance assessment
2. Dashboard automatically shows recommended actions based on weak areas
3. Click "Terminé" to mark actions as completed
4. Click area cards in health snapshot to see details
5. Use quick actions for common tasks

### For Developers

**Adding new action types:**

1. Add enum value to `ActionItem.action_type`
2. Update `ActionItemGenerator#determine_action_type` logic
3. Implement corresponding frontend action handler

**Customizing priorities:**

Modify `ActionItemGenerator#determine_priority` thresholds

**Adding new quick actions:**

Update `QuickActionsPanel.svelte` grid with new action button

## Future Enhancements (Phase 2+)

- Regulatory deadline tracking (data breaches, SARs)
- Snooze functionality for action items
- Filter/search in action items inbox
- Historical trends charts
- AI-powered action recommendations
```

### Step 2: Run full test suite

Run: `bin/rails test`

Expected: All tests PASS

### Step 3: Manual testing checklist

- [ ] Dashboard loads without errors
- [ ] Action items appear after completing assessment
- [ ] Can mark action item as completed
- [ ] Can dismiss action item
- [ ] Quick actions panel shows correct data
- [ ] All quick action buttons work
- [ ] Compliance area cards display correct colors
- [ ] Can expand/collapse area cards
- [ ] Mobile responsive layout works

### Step 4: Commit documentation

```bash
git add docs/features/compliance-dashboard.md
git commit -m "docs: add compliance dashboard feature documentation"
```

---

## Final Checklist

Before considering Phase 1 complete:

- [ ] All tests passing (`bin/rails test`)
- [ ] Dashboard displays action items inbox
- [ ] Action items generated from assessments
- [ ] Can complete/dismiss action items
- [ ] Quick actions panel functional
- [ ] Compliance health snapshot with drill-down works
- [ ] Mobile responsive
- [ ] Documentation complete
- [ ] Code reviewed and refactored
- [ ] No console errors in browser
- [ ] Accessibility basics (keyboard navigation, ARIA labels)

## Next Steps

After Phase 1 is complete and validated:

**Phase 2:** Incident Management (Data Breaches & SARs)
- Create `DataBreach` and `SubjectAccessRequest` models
- Add deadline tracking
- Integrate with action items inbox

**Phase 3:** Guided Workflows
- Breach notification wizard
- SAR response wizard
- Document template generation

**Phase 4:** Intelligence & Trends
- Historical charts
- Assessment scoring integration
- AI assistant integration
