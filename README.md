# nfc_sample

A NFC sample Flutter project.

# Run to generated code with buiild_runner and freezed
- You setup build environment for the first time.
- You modified any code with the annotation `@freezed`.

```
flutter pub run build_runner build --delete-conflicting-outputs
```

# Run to build apk
- Build debug
```
flutter build apk --debug
```

- Build release
```
flutter build apk
```
