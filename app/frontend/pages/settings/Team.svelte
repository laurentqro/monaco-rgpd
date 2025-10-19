<script>
  import SettingsLayout from '../../components/SettingsLayout.svelte'
  import { Button } from '$lib/components/ui/button'
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card'
  import { Alert, AlertDescription } from '$lib/components/ui/alert'
  import { Badge } from '$lib/components/ui/badge'
  import { Avatar, AvatarFallback } from '$lib/components/ui/avatar'
  import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
  } from '$lib/components/ui/table'

  let { members, is_admin } = $props()

  function getInitials(member) {
    return member.name?.[0]?.toUpperCase() || member.email?.[0]?.toUpperCase() || 'U'
  }

  function getRoleBadgeVariant(role) {
    if (role === 'owner') return 'default'
    if (role === 'admin') return 'secondary'
    return 'outline'
  }
</script>

<SettingsLayout>
  {#snippet children()}
    <Card>
      <CardHeader>
        <div class="flex justify-between items-center">
          <div>
            <CardTitle>Membres de l'équipe</CardTitle>
            <CardDescription>Gérez les membres de votre équipe</CardDescription>
          </div>
          {#if is_admin}
            <Button disabled variant="outline">
              Inviter un membre
            </Button>
          {/if}
        </div>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Membre</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Rôle</TableHead>
              <TableHead class="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {#each members as member}
              <TableRow>
                <TableCell>
                  <div class="flex items-center space-x-3">
                    <Avatar>
                      <AvatarFallback>{getInitials(member)}</AvatarFallback>
                    </Avatar>
                    <span class="font-medium">{member.name || member.email}</span>
                  </div>
                </TableCell>
                <TableCell>
                  <span class="text-muted-foreground">{member.email}</span>
                </TableCell>
                <TableCell>
                  <Badge variant={getRoleBadgeVariant(member.role)}>
                    {member.role}
                  </Badge>
                </TableCell>
                <TableCell class="text-right">
                  {#if is_admin && member.role !== 'owner'}
                    <Button disabled variant="ghost" size="sm">
                      Gérer
                    </Button>
                  {/if}
                </TableCell>
              </TableRow>
            {/each}
          </TableBody>
        </Table>

        <Alert class="mt-6">
          <AlertDescription>
            <strong>Bientôt disponible :</strong> Inviter des membres, gérer les rôles et supprimer des utilisateurs.
          </AlertDescription>
        </Alert>
      </CardContent>
    </Card>
  {/snippet}
</SettingsLayout>
