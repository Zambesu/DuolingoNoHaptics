# DuoNoHaptics

A small experimental iOS ARM64 dynamic library that suppresses UIKit's
`UIImpactFeedbackGenerator`, `UISelectionFeedbackGenerator`, and
`UINotificationFeedbackGenerator` feedback methods. It does not hook audio APIs.

## Build on GitHub (no Mac required locally)

1. Create a GitHub repository and upload the contents of this folder, preserving
   the `.github/workflows/build.yml` path.
2. Open the repository's **Actions** tab.
3. Select **Build DuoNoHaptics** and choose **Run workflow**.
4. When the run completes successfully, download the
   `DuoNoHaptics-ios-arm64` artifact. Extract the ZIP to obtain
   `DuoNoHaptics.dylib`.
5. In KSign, import the `.dylib` under the app's **Tweaks** section, enable it,
   then sign the IPA with the same certificate/profile used for the app.

## Important limitations

- This is an experimental first pass, not a tested fix for the Ipaomtk Duolingo
  build or iOS 27.
- It suppresses UIKit generator feedback only. If the repeating pulse is driven
  by Core Haptics or another/private API, this library will not stop it.
- A successful compile does not prove that KSign injects/loads the library
  correctly. Keep the original IPA and app data backed up before replacing it.
- Do not share signing certificates, private keys, or provisioning profiles
  with GitHub or include them in this repository.
