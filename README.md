# Gridfire Swift iOS Fixture

Controlled Stage 3 Swift/iOS fixture for Gridfire language productization.

This is a small real SwiftUI iOS app with a checked-in Xcode project, one app
target, one shared test scheme, deterministic unit and view-model tests, no
entitlements, no provisioning requirements, and no third-party dependencies.

The app models an on-call issue triage workflow. Users can search issues,
filter by triage state, mark issues resolved, and open issue details while
preserving list state.

## Baseline commands

Local Mini baseline:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export PATH="$DEVELOPER_DIR/usr/bin:$PATH"
xcodebuild build \
  -project GridfireSwiftIOSFixture.xcodeproj \
  -scheme GridfireSwiftIOSFixture \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' \
  -derivedDataPath /tmp/gridfire-swift-ios-fixture-derived-build \
  CODE_SIGNING_ALLOWED=NO
xcodebuild test \
  -project GridfireSwiftIOSFixture.xcodeproj \
  -scheme GridfireSwiftIOSFixture \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' \
  -derivedDataPath /tmp/gridfire-swift-ios-fixture-derived \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO
```

GitHub Actions uses `macos-26`, `/Applications/Xcode.app`, and an explicitly
verified `iPhone 17` simulator destination before build/test.
