# RMHook-iOS

This project is an early proof of concept for hooking or modifying the reMarkable iOS app. It currently does not work, possibly due to SSL/TLS issues in the custom networking stack used by the app.

## Project Structure
- `src/` – Contains the tweak source code and configuration files.
- `IPAs/` – Example reMarkable app IPA files for analysis.

## Build & Usage

### Build the Tweak
```sh
cd src && make clean && make package THEOS_PACKAGE_SCHEME=rootless
```

### Patch the IPA with the Tweak
```sh
cyan -i reMarkable.ipa \
	-o reMarkable_patched.ipa \
	-f xyz.noham.rmhook_0.0.1-1+debug_iphoneos-arm64.deb -u
```

### Debug Logging
```sh
log stream | grep RMHook
```

## Technical Notes
See [info.md](info.md) for detailed analysis of the app's networking stack and reverse engineering notes.

## Disclaimer
This project is for educational and research purposes only. It is not affiliated with or endorsed by reMarkable.