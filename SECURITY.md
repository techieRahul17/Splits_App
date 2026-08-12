# Security Policy

## Supported versions

Splits is developed on `main`, and fixes land there first. Only the most recent release
receives security updates.

| Version        | Supported          |
| -------------- | ------------------ |
| 1.0.x          | Yes                |
| Older than 1.0 | No                 |

---

## Reporting a vulnerability

**Please do not open a public issue for a security problem.** A public report tells
everyone about the weakness before there is a fix available.

Instead, report it privately through either of these:

1. **GitHub Private Vulnerability Reporting**, from the **Security** tab of this
   repository. This is preferred, since it keeps the discussion attached to the code.
2. **Email** to **CONTACT_EMAIL**.

### What to include

The more of this you can provide, the faster we can confirm and fix the issue:

- The type of issue and the component it affects
- Steps to reproduce, or a proof of concept
- The app version, device, and OS version
- What an attacker could achieve by exploiting it
- Any suggested fix, if you have one in mind

### What to expect

- **Acknowledgement** within 72 hours that we have received your report
- **An initial assessment**, confirming or dismissing the issue, within 7 days
- **Progress updates** at least every 14 days while we work on a fix
- **Credit** in the release notes when the fix ships, unless you would rather stay
  anonymous

We ask that you give us a reasonable window to release a fix before disclosing publicly.

---

## How Splits handles your data

Understanding the app's design will help you judge whether something is a real
vulnerability.

**Splits has no backend.** There is no server, no account, and no telemetry. The app never
transmits your groups, expenses, or contacts anywhere.

All data is stored locally on the device using Hive, in the app's private storage
directory. This includes:

- Group names, member names, and per-group currency
- Splits, line items, and calculated shares
- Your display name and UPI ID, if you enter them in Settings

Because storage is local, uninstalling the app deletes the data permanently. There is no
backup or recovery, and no way for us to retrieve anything for you.

### Outbound links

The app opens external applications in three situations. In each case it hands a URL to
the operating system and nothing more:

| Action              | Destination                     | What is shared                              |
| ------------------- | ------------------------------- | ------------------------------------------- |
| Pay via UPI         | Your installed UPI app          | Payee UPI ID, amount, currency, and a note   |
| Remind on WhatsApp  | WhatsApp                        | A message you can review before sending      |
| Share summary       | The system share sheet          | The summary text you chose to share          |

Nothing is sent in the background, and nothing is sent without an explicit tap.

### On UPI identifiers

A UPI ID is a payment address. It is not a secret in the way a password is, and it is
normally shared to receive money. Even so, it is personal data, so treat any bug that
exposes one unexpectedly, for example to another app on the device, as worth reporting.

---

## Scope

### In scope

- Unauthorised access to locally stored data by another app on the device
- A flaw allowing a crafted deep link or share payload to alter or exfiltrate stored data
- Incorrect construction of UPI links, particularly anything that could send money to an
  unintended recipient or for an unintended amount
- Exposure of personal data through logs, crash reports, or backups
- Dependency vulnerabilities that are actually reachable from this app's code

### Out of scope

- Attacks that require a rooted or jailbroken device, or physical access to an unlocked
  phone
- Vulnerabilities only reachable with a debug build or developer tooling attached
- Data loss from uninstalling the app, which is expected behaviour given local-only storage
- Reports from automated scanners with no demonstrated exploit path
- Social engineering of the maintainers or other users

---

## For contributors

If you are submitting code, please keep these in mind:

- Never commit secrets. Signing keys, keystores, `key.properties`, `local.properties`, and
  `.env` files are all excluded by `.gitignore`. Verify with `git status` before you commit.
- Do not log personal data. Member names, UPI IDs, and amounts should not appear in
  production logging.
- Do not add analytics, crash reporting, or any network call without discussing it in an
  issue first. The app's local-only guarantee is a deliberate design decision, and adding
  a network dependency changes the privacy promise made here.
- Keep dependencies current, and prefer well-maintained packages.
