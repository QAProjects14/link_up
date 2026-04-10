# LinkUp App Distribution Guide

How to build and distribute LinkUp using **GitHub only** (free, no extra accounts needed).

Both QR codes are permanent — you only repeat the build + upload steps for each update.

---

## Android Distribution

### Step 1 — Build the APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Rename to **`linkup.apk`** before uploading.

---

### Step 2 — Upload to GitHub Releases

#### First time

1. Go to [github.com/new](https://github.com/new) → create a **public** repo named `link_up` under `QAProjects14`.
2. Open the repo → **Releases** → **Create a new release**.
3. Tag: `latest` (type it, select "Create new tag: latest").
4. Title: `LinkUp vX.X`.
5. Drag in `linkup.apk` → **Publish release**.

Permanent APK URL:
```
https://github.com/QAProjects14/link_up/releases/latest/download/linkup.apk
```

#### Every update — replace the APK

1. Go to the `latest` release → **Edit release** (pencil icon).
2. Delete old `linkup.apk`, upload new one (same filename).
3. **Update release**.

The Android QR code URL never changes — no reprint needed.

---

## iOS Distribution

iOS uses **GitHub Pages** (free) to host a `manifest.plist` that tells iOS where to download the IPA from GitHub Releases.

### One-time GitHub Pages setup

1. In the `link_up` GitHub repo go to **Settings → Pages**.
2. Source: **Deploy from a branch** → Branch: `main` → Folder: `/docs`.
3. Click **Save**. GitHub will publish `https://qaprojects14.github.io/link_up/`.

The `docs/manifest.plist` file is already committed in this repo. The iOS QR encodes:
```
itms-services://?action=download-manifest&url=https://qaprojects14.github.io/link_up/manifest.plist
```

The manifest points to the IPA on GitHub Releases — same release as the APK.

---

### Step 1 — Build the IPA

```bash
flutter build ipa --export-method ad-hoc
```

Output: `build/ios/ipa/lyceum_notif.ipa`

Rename to **`linkup.ipa`** before uploading.

> **Signing note:** The IPA must be signed with an Apple Developer certificate.  
> - **Ad-Hoc**: Works only on devices with UDIDs registered in your provisioning profile (Apple Developer Program, $99/yr).  
> - **Enterprise**: Works on any iPhone without UDID registration (Enterprise Program, $299/yr).  
> Register testers' UDIDs in your Apple Developer account before building.

---

### Step 2 — Upload the IPA to the same GitHub Release

1. Go to the `latest` release → **Edit release**.
2. Upload `linkup.ipa` alongside `linkup.apk`.
3. **Update release**.

Permanent IPA URL (referenced inside `manifest.plist`):
```
https://github.com/QAProjects14/link_up/releases/latest/download/linkup.ipa
```

---

### Every future iOS update

1. Build new `linkup.ipa`.
2. Edit the `latest` GitHub Release → replace `linkup.ipa`.
3. Bump `bundle-version` in `docs/manifest.plist` → commit + push.

The iOS QR code URL never changes.

---

## Updating manifest.plist

`docs/manifest.plist` in this repo:

| Field | Value |
|-------|-------|
| `bundle-identifier` | `com.example.lyceumNotif` |
| `bundle-version` | Bump on every release (e.g. `1.0.1`) |
| IPA URL | `https://github.com/QAProjects14/link_up/releases/latest/download/linkup.ipa` |

---

## Quick Reference

| Action | Command / URL |
|--------|---------------|
| Build APK | `flutter build apk --release` |
| Build IPA | `flutter build ipa --export-method ad-hoc` |
| APK download URL | `https://github.com/QAProjects14/link_up/releases/latest/download/linkup.apk` |
| IPA download URL | `https://github.com/QAProjects14/link_up/releases/latest/download/linkup.ipa` |
| iOS manifest URL | `https://qaprojects14.github.io/link_up/manifest.plist` |
| iOS QR installs from | `itms-services://?action=download-manifest&url=https://qaprojects14.github.io/link_up/manifest.plist` |
| Update Android | Edit `latest` release on GitHub, replace `linkup.apk` |
| Update iOS | Edit `latest` release, replace `linkup.ipa` + bump version in `docs/manifest.plist` |
| QR code screen | QAO App → App Distribution |
