# Security Policy

## Supported Versions

The following table outlines the active support lifecycle and security update availability across all packages in the monorepo:

| Package | Supported Version | Status |
| --- | --- | --- |
| `baktaz_server` | 1.x.x | :white_check_mark: Active Security Support |
| `baktaz_flutter` | 1.x.x | :white_check_mark: Active Security Support |
| `baktaz_admin` | 1.x.x | :white_check_mark: Active Security Support |
| `baktaz_shared` | 1.x.x | :white_check_mark: Active Security Support |

---

## Reporting a Vulnerability

We take the security of Baktaz seriously. If you discover a vulnerability or security flaw, please report it responsibly using one of the following official channels:

1. **GitHub Private Vulnerability Reporting**: Submit a confidential advisory via the **Security** tab of the GitHub repository under **Advisories** -> **Report a vulnerability**.
2. **Email**: Send detailed disclosure reports to `security@baktaz.dev`.

### Submission Guidelines
When reporting a vulnerability, please include:
- A detailed description of the vulnerability and its potential impact.
- Step-by-step reproduction instructions or a Proof of Concept (PoC).
- The specific package (`baktaz_server`, `baktaz_flutter`, `baktaz_admin`, `baktaz_shared`) affected.
- Any suggested remediation or patch details if available.

Please **do not** create public GitHub issues or discussions for unpatched security vulnerabilities.

---

## Response SLA

Our security team adheres to strict Service Level Agreements (SLAs) for vulnerability triage and remediation:

| Stage | Target Timeline | Details |
| --- | --- | --- |
| **Acknowledgment** | 24–48 hours | Initial receipt confirmation and preliminary assessment. |
| **Triage** | 3 business days | Severity scoring (CVSS v3.1) and verification of reproduction steps. |
| **Patch (High / Critical)** | 7–14 days | Remediation patch developed, tested, and released to production. |
| **Patch (Medium / Low)** | 30 days | Security update packaged into the next planned minor release cycle. |

---

## Monorepo Security Requirements

### 1. API Secret & Credential Handling
- **Serverpod Secret Management**: All production secrets, database credentials, and service keys must be injected into Serverpod using `SERVERPOD_PASSWORDS_*` environment variables or secure key vaults. Never hardcode credentials in source code or `.spy.yaml` files.
- **Client Isolation**: Mobile (`baktaz_flutter`), Web/Desktop (`baktaz_admin`), and shared components (`baktaz_shared`) must never bundle admin API secrets, backend private keys, or server database credentials.

### 2. Session & Auth Architecture
- **Serverpod Session Validation**: All RPC endpoints in `baktaz_server` must validate incoming Serverpod `Session` objects and enforce explicit scope checks (e.g., verifying user authentication and admin authorization scopes).
- **Secure Token Storage**: Client applications (`baktaz_flutter`, `baktaz_admin`) must store authentication tokens, session secrets, and sensitive tokens using secure platform storage (`flutter_secure_storage` with OS-level keychains/keystores).

### 3. Data Protection & Transport
- **Transport Security**: Mandatory TLS 1.3/1.2 enforcement for all client-to-server and inter-service communication. Plaintext HTTP traffic is rejected in production.
- **Database & Query Safety**: All database interactions in `baktaz_server` must use Serverpod's ORM and parameterized queries to prevent SQL injection vulnerabilities.
- **Error Information Leakage**: Backend exceptions and internal stack traces must be caught, logged internally via `session.log()`, and sanitized before returning client responses to prevent internal architecture disclosure.

### 4. Environment Variable Handling in CI/CD Pipelines

Environment configuration handling is strictly separated between verification and deployment pipelines:

- **CI Verification Pipelines**:
  - Uses non-sensitive fallback environment files (copied from `assets/env/.env.development` or `.env.example`).
  - Allows `build_runner` codegen, static analysis (`dart analyze`), and automated unit/widget testing to succeed without requiring production secrets.
- **Build & Release Pipelines (CD / Flavors)**:
  - Build workflows for Staging and Production flavors inject actual secret environment variables from GitHub Repository Secrets directly into `assets/env/.env.staging` and `assets/env/.env.production`.
  - Secret injection occurs immediately before executing `flutter build <apk|ipa|web>`.

#### Example GitHub Actions Build & Release Workflow

```yaml
name: Build & Release Workflow

on:
  push:
    tags:
      - 'v*'

jobs:
  build-staging:
    name: Build Staging Flavor
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Inject Staging Secrets
        run: |
          cat <<EOF > baktaz_flutter/assets/env/.env.staging
          API_BASE_URL=${{ secrets.STAGING_API_BASE_URL }}
          API_KEY=${{ secrets.STAGING_API_KEY }}
          SENTRY_DSN=${{ secrets.STAGING_SENTRY_DSN }}
          EOF

      - name: Build Staging APK
        run: |
          cd baktaz_flutter
          flutter pub get
          flutter build apk --flavor staging -t lib/main_staging.dart

  build-production:
    name: Build Production Flavor
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Inject Production Secrets
        run: |
          cat <<EOF > baktaz_flutter/assets/env/.env.production
          API_BASE_URL=${{ secrets.PROD_API_BASE_URL }}
          API_KEY=${{ secrets.PROD_API_KEY }}
          SENTRY_DSN=${{ secrets.PROD_SENTRY_DSN }}
          EOF

      - name: Build Production APK
        run: |
          cd baktaz_flutter
          flutter pub get
          flutter build apk --flavor production -t lib/main_production.dart
```
