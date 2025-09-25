# Firebase Deployment Setup Instructions

## Prerequisites
Your Firebase project ID is: `nutridev-8ef2d`

## Step 1: Generate Firebase Service Account Key

Run the following command to generate a service account key:

```bash
firebase projects:addfirebase nutridev-8ef2d
```

Then generate the service account:

```bash
firebase init hosting:github
```

This will:
1. Generate a service account key
2. Automatically create the GitHub secret
3. Set up the deployment workflow

## Step 2: Manual Service Account Setup (Alternative)

If the automatic setup doesn't work, follow these steps:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project `nutridev-8ef2d`
3. Go to IAM & Admin > Service Accounts
4. Click "Create Service Account"
5. Name it `github-actions` 
6. Grant it these roles:
   - Firebase Hosting Admin
   - Cloud Build Service Account
7. Create and download the JSON key
8. Go to your GitHub repository settings
9. Go to Secrets and Variables > Actions
10. Create a new secret named `FIREBASE_SERVICE_ACCOUNT_NUTRIDEV_8EF2D`
11. Paste the entire JSON content as the secret value

## Step 3: Enable Firebase Hosting

```bash
firebase use nutridev-8ef2d
firebase init hosting
```

Choose:
- What do you want to use as your public directory? `build/web`
- Configure as a single-page app? `Yes`
- Set up automatic builds and deploys with GitHub? `Yes`

## Step 4: Test Deployment

After setting up the secrets, push your code to trigger automatic deployment:

```bash
git add .
git commit -m "Add Firebase hosting with GitHub Actions"
git push origin main
```

## Step 5: Access Your Deployed App

After deployment, your app will be available at:
`https://nutridev-8ef2d.web.app`

## Troubleshooting

If deployment fails:
1. Check GitHub Actions logs in your repository
2. Verify the service account key is correctly set in GitHub secrets
3. Ensure Firebase Hosting is enabled for your project
4. Check that the project ID matches in all configuration files
