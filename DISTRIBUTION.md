# LinkUp App Distribution Guide

How to build and distribute a new version of the LinkUp app using **GitHub Releases** (free, no paid plan needed).

The QR code URL never changes — you only repeat Steps 1–2 for every update.

---

## Step 1 — Build the Android APK

Inside the `lyceum_notif/` project folder, run:

```bash
flutter build apk --release
```

Output file:
```
build/app/outputs/flutter-apk/app-release.apk
```

Rename it to **`linkup.apk`** before uploading.

---

## Step 2 — Upload to GitHub Releases (first time + every update)

### First time — create the repo and first release

1. Go to https://github.com/new and create a **public** repository named `lyceum_notif` under the account `QAProject14`.
2. Open the repo → click **Releases** (right sidebar) → **Create a new release**.
3. Set the tag to `latest` (type it and select "Create new tag: latest").
4. Set the title to `LinkUp vX.X`.
5. Drag and drop `linkup.apk` into the assets area.
6. Click **Publish release**.

The permanent download URL will be:
```
https://github.com/QAProjects14/link_up/releases/latest/download/linkup.apk
```

### Every future update — replace the APK in the same release

1. Go to the `latest` release on GitHub.
2. Click **Edit release** (pencil icon).
3. Delete the old `linkup.apk` asset, upload the new one (same filename).
4. Click **Update release**.

The QR code URL stays the same — no reprinting needed.

---

## Step 3 — Verify it works

On an Android phone, open a browser and paste this URL:
```
https://github.com/QAProjects14/link_up/releases/latest/download/linkup.apk
```
The APK should download immediately. If it does, the QR code works.

---

## iOS Distribution

iOS requires TestFlight (Apple's policy — cannot sideload APKs).

1. Build: `flutter build ipa`
2. Upload to App Store Connect, invite testers via TestFlight.
3. Share the TestFlight link directly with iOS users.

---

## Quick Reference

| Action | Notes |
|--------|-------|
| Build APK | `flutter build apk --release` |
| APK download URL | `https://github.com/QAProjects14/link_up/releases/latest/download/linkup.apk` |
| Update app | Edit the `latest` release on GitHub, replace `linkup.apk` |
| QR code screen | QAO App → App Distribution |
