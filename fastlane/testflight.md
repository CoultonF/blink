# Blink Shell - TestFlight Build Setup

This guide walks you through setting up automated TestFlight builds for Blink Shell using GitHub Actions.

## Prerequisites

- Apple Developer Account ($99/year for 1-year signing)
- GitHub Account
- Your fork of this repository

## Required Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

### From Apple Developer Account (4 secrets)

| Secret | Description | How to Get |
|--------|-------------|------------|
| `TEAMID` | Your Apple Team ID | [Apple Developer](https://developer.apple.com/account) → Membership Details |
| `FASTLANE_KEY_ID` | App Store Connect API Key ID | [App Store Connect](https://appstoreconnect.apple.com/access/integrations/api) → Keys → Key ID |
| `FASTLANE_ISSUER_ID` | App Store Connect Issuer ID | [App Store Connect](https://appstoreconnect.apple.com/access/integrations/api) → Keys → Issuer ID (at top) |
| `FASTLANE_KEY` | API Key contents (full file) | Download the `.p8` file and paste entire contents including BEGIN/END lines |

### From GitHub (2 secrets)

| Secret | Description | How to Get |
|--------|-------------|------------|
| `GH_PAT` | GitHub Personal Access Token | [GitHub Settings](https://github.com/settings/tokens) → Generate with `repo` and `workflow` scopes |
| `MATCH_PASSWORD` | Password for certificate encryption | Create any strong password - this encrypts your certs in the Match-Secrets repo |

## Setup Steps

### Step 1: Create App Store Connect API Key

1. Go to [App Store Connect → Users and Access → Integrations → Keys](https://appstoreconnect.apple.com/access/integrations/api)
2. Click the **+** button to create a new key
3. Name it something like "Blink GitHub Actions"
4. Select **Admin** access
5. Download the `.p8` file (you can only download it once!)
6. Note the **Key ID** and **Issuer ID**

### Step 2: Create Match-Secrets Repository

1. Create a **private** repository named `Match-Secrets` in your GitHub account
2. This will store your encrypted certificates and provisioning profiles
3. Leave it empty - Fastlane will populate it

### Step 3: Add Secrets to GitHub

1. Go to your Blink fork → Settings → Secrets and variables → Actions
2. Add all 6 secrets from the tables above

### Step 4: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/apps) → My Apps
2. Click **+** → New App
3. Fill in:
   - Platform: iOS
   - Name: Blink Shell (or your preferred name)
   - Primary Language: English
   - Bundle ID: `sh.blink.blinkshell`
   - SKU: `blinkshell` (or any unique identifier)

### Step 5: Run the Workflows (in order)

Go to your fork → Actions tab, then run these workflows in order:

1. **1. Validate Secrets** - Verifies all secrets are set correctly
2. **2. Add Identifiers** - Creates app IDs in Apple Developer Portal
3. **3. Create Certificates** - Generates signing certificates and provisioning profiles
4. **4. Build Blink** - Builds and uploads to TestFlight

### Step 6: Configure App Groups (Manual)

After running "Add Identifiers", go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list) and:

1. Find `sh.blink.blinkshell` → Edit → App Groups → Configure
2. Create App Group: `group.sh.blink`
3. Do the same for the file provider extensions

## Automatic Builds

The `Build Blink` workflow runs automatically:
- **Weekly** on Sundays at 7:00 AM UTC
- **Monthly** (2nd Sunday) even without upstream changes
- This ensures your TestFlight build never expires (90-day limit)

To sync with upstream updates from blinksh/blink, the workflow automatically merges changes.

## Manual Build

Trigger a build anytime:
1. Go to Actions → "4. Build Blink" (or "Build Blink" for the scheduled version)
2. Click "Run workflow"
3. Optionally check "Force build even without changes"

## Troubleshooting

### "Missing provisioning profile"
Run workflow "3. Create Certificates" again.

### "No signing certificate"
Your certificates may have expired. Run "3. Create Certificates" to regenerate.

### "App ID not found"
Run workflow "2. Add Identifiers" to create the bundle identifiers.

### Build fails with signing errors
1. Check that your TEAMID is correct
2. Ensure the app exists in App Store Connect with bundle ID `sh.blink.blinkshell`
3. Verify App Groups are configured correctly

## Certificate Renewal

Certificates are valid for 1 year. When they expire:
1. Run "3. Create Certificates" workflow
2. Fastlane Match will automatically regenerate them

## Files Created

```
fastlane/
  Fastfile      # Build lanes
  Matchfile     # Certificate config
  Appfile       # App metadata
Gemfile         # Ruby dependencies
.github/workflows/
  1_validate_secrets.yml
  2_add_identifiers.yml
  3_create_certificates.yml
  4_build_blink.yml
  build_blink.yml  # Automated weekly builds
```
