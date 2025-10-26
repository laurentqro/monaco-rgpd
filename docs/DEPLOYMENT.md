# Deployment Guide

## Continuous Deployment

This project uses GitHub Actions for automated deployment to production via Kamal.

### Workflow

1. **Push to `master`**: Triggers automated deployment
2. **Tests run**: Full test suite must pass
3. **Deploy**: Kamal deploys to production server

### GitHub Secrets Required

Configure these secrets in your GitHub repository settings:

#### Docker Registry
- `DOCKER_USERNAME`: Your Docker Hub username (currently: `laurentqro`)
- `DOCKER_PASSWORD`: Docker Hub access token

#### Server Access
- `SSH_PRIVATE_KEY`: SSH private key for accessing deployment servers
  - Must have access to web server (188.245.95.182)
  - Must have access to database server (168.119.155.205)

#### Application Secrets
- `RAILS_MASTER_KEY`: Rails master key for credentials decryption
- `POSTGRES_PASSWORD`: PostgreSQL database password
- `SMTP_USERNAME`: Brevo SMTP username
- `SMTP_PASSWORD`: Brevo SMTP password
- `APP_HOST`: Application host (e.g., `lecircuit.app`)
- `MAILER_FROM_EMAIL`: Email address for outgoing mail

### Manual Deployment

You can also trigger deployment manually:

1. Go to Actions tab in GitHub
2. Select "CD" workflow
3. Click "Run workflow"
4. Select the `master` branch

### Local Deployment

To deploy from your local machine:

```bash
# Ensure you have Kamal installed
gem install kamal

# Deploy
kamal deploy

# Or specific commands
kamal app deploy    # Deploy app only
kamal app restart   # Restart app
kamal app logs      # View logs
```

### Rollback

If a deployment fails or introduces issues:

```bash
# Rollback to previous version
kamal app rollback

# Or from GitHub Actions
# Re-run a previous successful deployment workflow
```

## Infrastructure

### Servers
- **Web**: 188.245.95.182 (lecircuit.app)
- **Database**: 168.119.155.205 (PostgreSQL 17)

### Services
- **Proxy**: Traefik with Let's Encrypt SSL
- **Database**: PostgreSQL 17
- **Email**: Brevo SMTP relay

## Monitoring

After deployment, verify:

1. Application is running: `kamal app logs`
2. Database is accessible: `kamal app exec "bin/rails db:migrate:status"`
3. SSL certificate is valid: Visit https://lecircuit.app
4. Health check passes: Check application health endpoint

## Troubleshooting

### Deployment fails

```bash
# Check deployment logs
kamal app logs

# Check container status
kamal app details

# SSH into server
ssh root@188.245.95.182
```

### Database issues

```bash
# Check database status
kamal accessory details db

# Run database console
kamal app exec --interactive "bin/rails dbconsole"
```

### Asset compilation issues

Ensure Vite builds successfully locally:

```bash
npm run build
```

If assets are missing in production, rebuild and redeploy.
