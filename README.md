# Don't Tap Rogue Op

A Flame-powered mobile game built with Flutter.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.41.6+)
- Java 17 (for Android builds)
- `keytool` (bundled with JDK)
- A GitHub repository with Actions enabled

---

## CI/CD — Automated Signed Builds

Every push to any branch triggers a GitHub Actions workflow that builds a **signed release APK** and **AAB**.

### How It Works

1. The workflow decodes a base64-encoded keystore from GitHub Secrets at runtime.
2. A temporary `key.properties` file is created with signing credentials.
3. Flutter builds both APK and AAB in **release mode** (never debug).
4. The keystore and `key.properties` are deleted from the runner after the build.
5. The signed APK and AAB are uploaded as downloadable workflow artifacts.

### Required GitHub Secrets

| Secret Name              | Description                                   |
| ------------------------ | --------------------------------------------- |
| `DontTapOpBase64`        | Base64-encoded `.jks` keystore file            |
| `DontTapOpStorePassword` | Password for the keystore                      |
| `DontTapOpKeyPassword`   | Password for the signing key                   |
| `DontTapOpKeyAlias`      | Alias of the signing key inside the keystore   |

### Downloading Artifacts

After a successful build, go to **Actions > (workflow run) > Artifacts** to download:
- `release-apk` — the signed `.apk`
- `release-aab` — the signed `.aab` (for Google Play upload)

---

## Generating a Keystore

A helper script is included to generate a release keystore and output the values needed for GitHub Secrets.

### Steps

1. **Run the script** from the project root:

   ```bash
   bash scripts/generate_keystore.sh
   ```

2. **Enter the prompted values.** The script asks for:
   - Key alias
   - Key password
   - Store password
   - Full name
   - Organization / Company name
   - Organizational unit / Team name
   - City / Locality
   - State / Province
   - Country code (2-letter)

3. **Copy the output** and add each value as a GitHub Secret (see table above).

4. **Delete the local `.jks` file** after you have copied the base64 string:

   ```bash
   rm donttapop-release.jks
   ```

### Privacy & Security Notice

- The keystore script **does NOT** collect, read, or transmit any system information, IP addresses, usernames, hostnames, MAC addresses, or location data.
- Every value is manually entered by the operator.
- No data is auto-filled or inferred from the environment.
- Keystore files and passwords must **never** be committed to version control.
- The `.gitignore` is configured to exclude `.jks`, `.keystore`, `key.properties`, and other sensitive files.

---

## Local Development

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK locally (requires android/key.properties)
flutter build apk --release

# Build release AAB locally (requires android/key.properties)
flutter build appbundle --release
```

### Local Signing (optional)

To build signed releases locally, create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=/absolute/path/to/your/keystore.jks
```

This file is already in `.gitignore` and will never be committed.

---

## Project Structure

```
├── .github/workflows/build.yml   # CI/CD workflow
├── android/
│   ├── app/
│   │   ├── build.gradle.kts      # Signing + ProGuard config
│   │   └── proguard-rules.pro    # R8 rules (Play Core dontwarn)
│   └── key.properties            # Local signing (gitignored)
├── lib/                          # Flutter/Dart source
├── scripts/
│   └── generate_keystore.sh      # Keystore generation helper
├── assets/                       # Images, audio, fonts
└── pubspec.yaml
```
