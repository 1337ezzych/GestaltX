# GestaltX — Mond-inspired SwiftUI prototype

Independent SwiftUI app with Home, MobileGestalt plist editor, Backups and Settings.

## Build unsigned IPA with GitHub Actions

1. Upload the contents of this folder to the `main` branch of your GitHub repository.
2. Open the repository's **Actions** tab.
3. Select **Build iOS IPA** and press **Run workflow**.
4. Open the completed run and download the **GestaltX-unsigned-IPA** artifact.

The generated IPA is unsigned. A physical iPhone requires a compatible signing method and certificate/profile before installation. Never commit signing certificates, provisioning profiles, private keys, or passwords to the repository.

## Local build

Requires macOS, Xcode and XcodeGen:

```sh
brew install xcodegen
xcodegen generate
open GestaltX.xcodeproj
```

## Scope

The app imports plist documents explicitly selected by the user, edits root-level values, exports XML plist files and stores local snapshots. It does not access protected iOS MobileGestalt files, bypass the iOS app sandbox, or modify system configuration.
