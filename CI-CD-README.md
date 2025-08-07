# CI/CD Pipeline Documentation

This project includes a comprehensive CI/CD pipeline using GitHub Actions for automated testing, building, and deployment.

## 🚀 Pipeline Overview

The CI/CD pipeline consists of the following stages:

1. **Lint and Test** - Code quality checks and testing
2. **Build** - Application building and artifact creation
3. **Security Scan** - Security vulnerability scanning
4. **Deploy Staging** - Deployment to staging environment (develop branch)
5. **Deploy Production** - Deployment to production environment (main branch)
6. **Performance Test** - Performance testing with Lighthouse (optional)

## 📁 File Structure

```
.github/
├── workflows/
│   ├── ci-cd.yml          # Main CI/CD pipeline
│   └── deploy-configs.yml # Deployment templates
├── Dockerfile             # Multi-stage Docker configuration
├── docker-compose.yml     # Local development setup
└── CI-CD-README.md       # This documentation
```

## 🔧 Setup Instructions

### 1. GitHub Repository Setup

1. Push your code to a GitHub repository
2. Enable GitHub Actions in your repository settings
3. Set up branch protection rules for `main` and `develop` branches

### 2. Environment Variables

Add the following secrets to your GitHub repository:

#### For Netlify Deployment:
- `NETLIFY_AUTH_TOKEN` - Your Netlify authentication token
- `NETLIFY_SITE_ID` - Your Netlify site ID

#### For Vercel Deployment:
- `VERCEL_TOKEN` - Your Vercel authentication token
- `ORG_ID` - Your Vercel organization ID
- `PROJECT_ID` - Your Vercel project ID

#### For AWS S3 Deployment:
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `S3_BUCKET` - S3 bucket name
- `CLOUDFRONT_DISTRIBUTION_ID` - CloudFront distribution ID (optional)

#### For Docker Hub:
- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub password

#### For Security Scanning:
- `SNYK_TOKEN` - Snyk authentication token (optional)

### 3. Branch Strategy

- `main` branch: Production deployments
- `develop` branch: Staging deployments
- Feature branches: Trigger linting and testing only

## 🛠️ Local Development

### Using Docker Compose

```bash
# Development environment
docker-compose up app-dev

# Production environment
docker-compose up app-prod

# Testing environment
docker-compose up app-test
```

### Manual Setup

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run linting
npm run lint
```

## 🔄 Pipeline Stages

### 1. Lint and Test Stage
- **Trigger**: All pushes and pull requests
- **Actions**:
  - Code linting with ESLint
  - Type checking (if TypeScript is added)
  - Unit tests (if test scripts are added)

### 2. Build Stage
- **Trigger**: After successful lint and test
- **Actions**:
  - Install dependencies
  - Build application with Vite
  - Upload build artifacts

### 3. Security Scan Stage
- **Trigger**: After successful build
- **Actions**:
  - npm audit for dependency vulnerabilities
  - Snyk security scanning (optional)

### 4. Deploy Stages
- **Staging**: Triggered on `develop` branch
- **Production**: Triggered on `main` branch
- **Actions**: Deploy to respective environments

### 5. Performance Test Stage
- **Trigger**: Only on `main` branch
- **Actions**: Lighthouse performance testing

## 🚀 Deployment Options

### 1. Netlify Deployment

Add this job to your main pipeline:

```yaml
- name: Deploy to Netlify
  uses: nwtgck/actions-netlify@v2.0
  with:
    publish-dir: './dist'
    production-branch: main
    github-token: ${{ secrets.GITHUB_TOKEN }}
    deploy-message: "Deploy from GitHub Actions"
  env:
    NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
    NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

### 2. Vercel Deployment

Add this job to your main pipeline:

```yaml
- name: Deploy to Vercel
  uses: amondnet/vercel-action@v25
  with:
    vercel-token: ${{ secrets.VERCEL_TOKEN }}
    vercel-org-id: ${{ secrets.ORG_ID }}
    vercel-project-id: ${{ secrets.PROJECT_ID }}
    working-directory: ./
```

### 3. AWS S3 Deployment

Add this job to your main pipeline:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-east-1

- name: Deploy to S3
  run: aws s3 sync dist/ s3://${{ secrets.S3_BUCKET }} --delete
```

### 4. GitHub Pages Deployment

Add this job to your main pipeline:

```yaml
- name: Setup Pages
  uses: actions/configure-pages@v4

- name: Upload artifact
  uses: actions/upload-pages-artifact@v3
  with:
    path: dist/

- name: Deploy to GitHub Pages
  uses: actions/deploy-pages@v4
```

## 🔍 Monitoring and Notifications

### Slack Notifications

Add this step to your deployment jobs:

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    channel: '#deployments'
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Email Notifications

Add this step to your deployment jobs:

```yaml
- name: Send email notification
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 587
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: "Deployment ${{ job.status }}"
    to: ${{ secrets.NOTIFICATION_EMAIL }}
    from: "CI/CD Pipeline"
    body: "Deployment to ${{ github.ref_name }} has ${{ job.status }}"
```

## 🛡️ Security Best Practices

1. **Secrets Management**: All sensitive data is stored as GitHub secrets
2. **Branch Protection**: Require status checks to pass before merging
3. **Dependency Scanning**: Regular security scans with npm audit and Snyk
4. **Container Security**: Multi-stage Docker builds with minimal attack surface
5. **Environment Isolation**: Separate staging and production environments

## 📊 Performance Monitoring

The pipeline includes Lighthouse CI for performance testing:

- **Performance Score**: Minimum 90
- **Accessibility Score**: Minimum 90
- **Best Practices Score**: Minimum 90
- **SEO Score**: Minimum 90

## 🔧 Troubleshooting

### Common Issues

1. **Build Failures**: Check Node.js version compatibility
2. **Deployment Failures**: Verify environment secrets are correctly set
3. **Security Scan Failures**: Review and update vulnerable dependencies
4. **Performance Test Failures**: Optimize bundle size and loading times

### Debug Commands

```bash
# Check build locally
npm run build

# Test Docker build
docker build -t eyewebsite .

# Run security audit
npm audit

# Check bundle size
npm run build && npx vite-bundle-analyzer dist
```

## 📈 Future Enhancements

1. **Automated Testing**: Add Jest/Vitest for unit and integration tests
2. **E2E Testing**: Add Playwright or Cypress for end-to-end testing
3. **Database Migrations**: Add database migration scripts
4. **Rollback Strategy**: Implement automated rollback on deployment failures
5. **Blue-Green Deployment**: Implement zero-downtime deployments
6. **Monitoring Integration**: Add application performance monitoring (APM)

## 📞 Support

For issues with the CI/CD pipeline:

1. Check GitHub Actions logs for detailed error messages
2. Verify all required secrets are properly configured
3. Ensure branch protection rules are correctly set
4. Review deployment platform-specific documentation

---

**Last Updated**: $(date)
**Pipeline Version**: 1.0.0 