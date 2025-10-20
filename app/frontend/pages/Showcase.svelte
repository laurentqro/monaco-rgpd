<script>
  import { Button } from '$lib/components/ui/button';
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card';
  import { Input } from '$lib/components/ui/input';
  import { Label } from '$lib/components/ui/label';
  import { Textarea } from '$lib/components/ui/textarea';
  import { Checkbox } from '$lib/components/ui/checkbox';
  import { Badge } from '$lib/components/ui/badge';
  import { Alert, AlertDescription } from '$lib/components/ui/alert';
  import { Separator } from '$lib/components/ui/separator';
</script>

<div class="min-h-screen bg-gray-50 p-8">
  <div class="max-w-7xl mx-auto space-y-8">
    <div>
      <h1 class="text-4xl font-bold mb-2">shadcn-svelte Components</h1>
      <p class="text-gray-600">Component showcase for Monaco RGPD</p>
    </div>

    <Separator />

    <!-- Buttons -->
    <Card>
      <CardHeader>
        <CardTitle>Buttons</CardTitle>
        <CardDescription>Different button variants and sizes</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="flex flex-wrap gap-4">
          <Button>Default</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="destructive">Destructive</Button>
          <Button variant="outline">Outline</Button>
          <Button variant="ghost">Ghost</Button>
          <Button variant="link">Link</Button>
        </div>
        <div class="flex flex-wrap gap-4 mt-4">
          <Button size="sm">Small</Button>
          <Button size="default">Default</Button>
          <Button size="lg">Large</Button>
        </div>
      </CardContent>
    </Card>

    <!-- Forms -->
    <Card>
      <CardHeader>
        <CardTitle>Form Inputs</CardTitle>
        <CardDescription>Input fields and form controls</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="space-y-4 max-w-md">
          <div class="space-y-2">
            <Label for="email">Email</Label>
            <Input id="email" type="email" placeholder="email@example.com" />
          </div>
          <div class="space-y-2">
            <Label for="message">Message</Label>
            <Textarea id="message" placeholder="Type your message here..." />
          </div>
          <div class="flex items-center space-x-2">
            <Checkbox id="terms" />
            <Label for="terms">Accept terms and conditions</Label>
          </div>
        </div>
      </CardContent>
    </Card>

    <!-- Alerts & Badges -->
    <Card>
      <CardHeader>
        <CardTitle>Alerts & Badges</CardTitle>
        <CardDescription>Feedback and status indicators</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="space-y-4">
          <Alert>
            <AlertDescription>
              This is a default alert message.
            </AlertDescription>
          </Alert>
          <div class="flex gap-2">
            <Badge>Default</Badge>
            <Badge variant="secondary">Secondary</Badge>
            <Badge variant="destructive">Destructive</Badge>
            <Badge variant="outline">Outline</Badge>
          </div>
        </div>
      </CardContent>
    </Card>

  </div>
</div>
