# CODE SIGNING & GITHUB ACTIONS SECRETS GUIDE

This project's GitHub Actions workflow (`.github/workflows/ios-build.yml`) supports **two automatic modes** for building and exporting `PrincessPuzzle.ipa`:

---

## Mode 1: Unsigned / Ad-Hoc ARM64 Device IPA Export (Zero Secrets Required)

When no Apple Developer signing secrets are configured in the repository, the workflow automatically runs **Mode 1**:
1. Compiles and runs all 9 unit & integration tests (`PrincessPuzzleTests`) on an iPhone iOS Simulator.
2. Archives the application for generic iOS ARM64 devices (`-sdk iphoneos -destination "generic/platform=iOS"`) using `xcodebuild archive` with `CODE_SIGNING_ALLOWED=NO`.
3. Ad-hoc linker-signs the ARM64 Mach-O binary (`codesign --force --deep --sign -`) and packages `PrincessPuzzle.xcarchive/Products/Applications/PrincessPuzzle.app` into a real, standards-compliant iOS Application Archive (`Payload/PrincessPuzzle.app` inside `PrincessPuzzle.ipa`).
4. Verifies the internal `Payload/PrincessPuzzle.app/PrincessPuzzle` ARM64 Mach-O binary and `Info.plist`.
5. Uploads `PrincessPuzzle.ipa` to **GitHub Actions Artifacts** under the artifact name **`PrincessPuzzle-iOS-IPA`** (and attaches `PrincessPuzzle.ipa` to the GitHub Release for 1-click download).

> **Installing Mode 1 IPAs:** An unsigned/ad-hoc `.ipa` can be installed on physical iPhones/iPads using AltStore, SideStore, Sideloadly (which re-signs with your personal Apple ID), or TrollStore.

---

## Mode 2: Signed Apple Distribution IPA Export (`xcodebuild -exportArchive`)

When you configure your Apple Developer credentials in **GitHub Repository → Settings → Secrets and variables → Actions**, the workflow automatically detects them and switches to **Mode 2**:

### Required GitHub Actions Secrets for Mode 2

| Secret Name | Description | How to Generate |
| :--- | :--- | :--- |
| `BUILD_CERTIFICATE_BASE64` | Base64-encoded Apple Distribution (or Development) `.p12` certificate file | `base64 -i Certificates.p12 \| pbcopy` (macOS) or `[Convert]::ToBase64String([IO.File]::ReadAllBytes("Certificates.p12"))` (PowerShell) |
| `P12_PASSWORD` | Password protecting the exported `.p12` certificate | The password you set when exporting `.p12` from Keychain Access |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64-encoded `.mobileprovision` file matching `com.thasmobi.physicsPuzzle05` (or your custom Bundle ID) | `base64 -i PrincessPuzzle.mobileprovision \| pbcopy` |
| `APPLE_TEAM_ID` | Your 10-character Apple Developer Team ID (e.g., `A1B2C3D4E5`) | Found in Apple Developer Account → Membership Details |
| `CODE_SIGN_IDENTITY` *(Optional)* | Signing identity name (defaults to `Apple Distribution`) | e.g., `Apple Distribution` or `Apple Development` |

### Security Guarantees Implemented in `.github/workflows/ios-build.yml`
- **No Hardcoded Secrets**: Certificates, private keys, passwords, and provisioning profiles are never stored in source control and are blocked in `.gitignore`.
- **Ephemeral Keychain**: Mode 2 creates a temporary random-password keychain (`$RUNNER_TEMP/princess_signing.keychain-db`) solely for the duration of the job.
- **Guaranteed Cleanup (`if: always()`)**: Step 11 deletes the temporary keychain, removes decoded `.p12` and `.mobileprovision` files from `$RUNNER_TEMP`, and purges the installed provisioning profile even if a build step fails.
