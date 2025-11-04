# AI Chat Interface

## Overview

The AI Chat interface provides a conversational alternative to the traditional questionnaire form. Users interact with an AI assistant that asks questions naturally while extracting structured data for compliance assessment.

## Architecture

### Data Flow

1. **User starts conversation** → ConversationOrchestrator creates Conversation
2. **AI sends welcome message** with first question
3. **User responds naturally** → Message stored
4. **AI extracts structured data** → Answer records created
5. **Process repeats** until all required data collected
6. **Conversation completed** → User sees results

### Models

#### Conversation
Stores conversation metadata:
- `questionnaire_id` - Which questionnaire is being answered
- `account_id` - Which account owns this conversation
- `response_id` - Links to Response model (optional, set when conversation starts)
- `status` - Enum: `in_progress`, `completed`, `abandoned`
- `started_at`, `completed_at` - Timestamps
- `metadata` - JSONB for additional data

Associations:
- `belongs_to :response, optional: true`
- `belongs_to :questionnaire`
- `belongs_to :account`
- `has_many :messages, dependent: :destroy`

#### Message
Individual messages with role (user/assistant/system):
- `conversation_id` - Parent conversation
- `role` - Enum: `user`, `assistant`, `system`
- `content` - Message text
- `extracted_data` - JSONB with confidence scores and extracted answers
- `question_id` - Optional link to specific question (for tracking)

Associations:
- `belongs_to :conversation`
- `belongs_to :question, optional: true`

### Services

#### ConversationOrchestrator
Main service coordinating AI interactions:
- **Manages conversation state** (in_progress → completed)
- **Calls Anthropic Claude API** with system prompts
- **Extracts data from responses** using JSON parsing
- **Creates Answer records** when confidence >= 0.7
- **Builds questionnaire structure** as JSON for AI context

Key methods:
- `self.start(questionnaire:, account:)` - Creates new conversation with welcome message
- `process_user_message(content)` - Handles user input and generates AI response
- `get_ai_response(user_message)` - Calls Anthropic API
- `create_answers_from_extraction(extracted_data)` - Creates Answer records

## Configuration

### Environment Variables

The application uses Rails credentials to store the Anthropic API key:

```yaml
# config/credentials.yml.enc
anthropic_api_key: your_api_key_here
```

Edit credentials with:
```bash
EDITOR=nano rails credentials:edit
```

### Anthropic SDK

Official Anthropic Ruby SDK (v1.13+):
```ruby
# config/initializers/anthropic.rb
ENV["ANTHROPIC_API_KEY"] ||= Rails.application.credentials.fetch(:anthropic_api_key)
```

## API Endpoints

```
POST /conversations                    # Start new conversation
GET  /conversations/:id                # View conversation
POST /conversations/:id/messages       # Send user message
```

### POST /conversations

**Parameters:**
- `questionnaire_id` (required)

**Response:**
- Renders `Chat/Show` Inertia page
- Includes conversation and questionnaire data

### POST /conversations/:id/messages

**Parameters:**
- `message[content]` (required) - User's message text

**Response:**
```json
{
  "message": {
    "id": 123,
    "role": "assistant",
    "content": "AI response text",
    "extracted_data": { ... },
    "created_at": "2025-01-04T22:00:00Z"
  },
  "next_action": "ask_next_question" | "clarify" | "complete"
}
```

## Frontend Components

### Chat/Show.svelte
Entry point page that renders ChatInterface.

### ChatInterface.svelte
Main container managing state and API calls:
- Handles message sending with optimistic updates
- Manages `isSending` state for UI feedback
- Redirects to results when conversation completes
- Uses Inertia.js for navigation

### MessageList.svelte
Message display with auto-scroll:
- Renders messages in chronological order
- Different styling for user vs assistant messages
- Auto-scrolls to bottom on new messages
- Shows typing indicator when AI is responding
- Uses Svelte 5 `$effect` for scroll behavior

### ChatInput.svelte
User input with keyboard shortcuts:
- Enter to send (Shift+Enter for new line)
- Disables when sending
- Clears input after send
- Uses Svelte 5 `$state` for reactivity

### ProgressSidebar.svelte
Shows completion progress:
- Calculates answered questions from extracted_data
- Displays progress bar
- Lists all questions with checkmarks for answered
- Uses Svelte 5 `$derived` for reactive calculations

### AnswerButtons.svelte
Clickable quick-select buttons for common answers:
- Renders when AI includes `suggested_buttons` in response
- Shows answer choices as buttons (e.g., "Oui"/"Non")
- Disables after selection
- Green/red styling for yes/no questions
- Check icon on selected button (lucide-svelte)
- Full accessibility with ARIA labels and keyboard navigation
- Fallback to text input always available

## AI Prompts

### System Prompt Structure

The system prompt includes:
1. **Role definition** - GDPR compliance assistant for Monaco (Loi n° 1.565)
2. **Questionnaire structure** - Full JSON with sections, questions, answer choices
3. **Task description** - Ask questions naturally, extract data, clarify ambiguities
4. **Response format** - JSON with message, extracted_data, and next_action

### Response Format

AI responses must be valid JSON:
```json
{
  "message": "Conversational response in French",
  "suggested_buttons": {
    "question_id": 22,
    "buttons": [
      {"choice_id": 1, "label": "Oui"},
      {"choice_id": 2, "label": "Non"}
    ]
  },
  "extracted_data": {
    "answers": [
      {
        "question_id": 123,
        "answer_type": "yes_no",
        "value": "Oui",
        "confidence": 0.95
      }
    ]
  },
  "next_action": "ask_next_question"
}
```

### When Buttons Appear

- **yes_no questions:** Two buttons (Oui/Non)
- **single_choice questions:** All available choices as buttons
- **text questions:** No buttons (user types freely)
- **Clarifications:** No buttons (conversational flow)

Users can always type instead of clicking buttons.

## Testing

### Unit Tests
```bash
# Model tests
bin/rails test test/models/conversation_test.rb
bin/rails test test/models/message_test.rb

# Service tests
bin/rails test test/services/conversation_orchestrator_test.rb

# Controller tests
bin/rails test test/controllers/conversations_controller_test.rb
```

### Integration Tests
```bash
# End-to-end chat flow
bin/rails test test/integration/ai_chat_flow_test.rb

# Clickable answer buttons
bin/rails test test/integration/ai_chat_buttons_test.rb
```

### Full Suite
```bash
bin/rails test
```

**Current Status:** 299 tests (4 conversation/button tests), all feature tests passing ✅

## Database Schema

### conversations table
```ruby
t.references :response, foreign_key: true, null: true
t.references :questionnaire, foreign_key: true, null: false
t.references :account, foreign_key: true, null: false
t.integer :status, default: 0, null: false
t.datetime :started_at
t.datetime :completed_at
t.jsonb :metadata, default: {}, null: false
t.timestamps

t.index [:account_id, :created_at]
```

### messages table
```ruby
t.references :conversation, foreign_key: true, null: false
t.integer :role, null: false
t.text :content, null: false
t.jsonb :extracted_data, default: {}, null: false
t.references :question, foreign_key: true, null: true
t.timestamps

t.index [:conversation_id, :created_at]
```

## Security Considerations

1. **Authentication Required** - All conversation endpoints require authenticated user
2. **Account Isolation** - Conversations scoped to `Current.account`
3. **API Key Protection** - Stored in encrypted Rails credentials
4. **Input Validation** - Message content validated in controller
5. **SQL Injection Prevention** - Using parameterized queries via ActiveRecord

## Performance

### Database Indexes
- `conversations`: `[account_id, created_at]` for listing
- `messages`: `[conversation_id, created_at]` for chronological retrieval

### Frontend Optimizations
- Optimistic UI updates for instant feedback
- Auto-scroll only when new messages arrive
- Lazy loading of questionnaire structure

### API Considerations
- Anthropic API calls are synchronous (consider async for production)
- Average response time: 2-5 seconds
- Rate limiting: Follow Anthropic API limits

## Future Enhancements

### Phase 2: Agent Tools
- Dynamic question selection based on previous answers
- Context-aware follow-up questions
- Smart branching logic

### Additional Features
- Conversation export/transcript download
- Multi-language support (currently French only)
- Voice input/output
- Conversation history and resume
- Real-time streaming responses (SSE)
- Analytics and insights dashboard

## Troubleshooting

### Common Issues

**Issue:** API connection errors in tests
**Solution:** Tests mock AI responses using `class_eval` to avoid real API calls

**Issue:** Conversation stuck in `in_progress`
**Solution:** Manual cleanup: `Conversation.in_progress.where('created_at < ?', 1.hour.ago).update_all(status: :abandoned)`

**Issue:** Missing API key error
**Solution:** Set credentials: `EDITOR=nano rails credentials:edit`

**Issue:** Frontend not showing chat button
**Solution:** Run `npm run build` to rebuild Svelte components

## Development

### Adding New Question Types

1. Update `create_answer_for_question` in ConversationOrchestrator
2. Add extraction logic for new answer type
3. Update AI system prompt with format instructions
4. Add test cases

### Modifying AI Behavior

Edit `build_system_prompt` in ConversationOrchestrator to:
- Change tone and style
- Add domain-specific instructions
- Modify response format
- Adjust confidence thresholds

## Deployment

### Production Checklist

- [ ] Set `ANTHROPIC_API_KEY` in production credentials
- [ ] Review Anthropic API rate limits
- [ ] Set up error monitoring for AI failures
- [ ] Configure timeout settings (current: 2048 max_tokens)
- [ ] Test with real Monaco RGPD compliance scenarios
- [ ] Add conversation analytics
- [ ] Set up backup for conversation data
- [ ] Review and adjust AI prompts based on usage

### Monitoring

Key metrics to track:
- Conversation completion rate
- Average conversation duration
- AI response accuracy (confidence scores)
- API error rates
- User satisfaction feedback

## References

- [Anthropic API Documentation](https://docs.anthropic.com/)
- [Official Anthropic Ruby SDK](https://github.com/anthropics/anthropic-sdk-ruby)
- [Svelte 5 Documentation](https://svelte.dev/)
- [Inertia.js Documentation](https://inertiajs.com/)
