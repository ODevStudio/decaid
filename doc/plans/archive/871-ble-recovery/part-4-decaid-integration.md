# #871 part 4/5: Decaid BLE recovery integration

- Issue: #876
- PR reviewed: #881 at `c9a22221dd08f9f42f261d9b628fa7d782ed3f23`
- Native admission PR: `tadelv/universal_ble#25` at
  `f61b5666e8b3542a043b2f0da8056b70d97da0df`
- Native lifecycle PR: `tadelv/universal_ble#28` at
  `1dca59494a684dbb6007e3b2819e7e11ee0ae987`, corrected locally at
  `546d55bbaef7f750c570b88d8c797299fc01335a`

## Decision

Decaid keeps UI policy, retry policy, scan ownership, and candidate adoption.
The `universal_ble` Android layer keeps native direct-connect admission and
exact GATT lifecycle ownership. Plugin BLE sessions continue to use the
existing plugin authorization and transport paths.

`ConnectionManager` owns one normalized device-id lease until the source
connect and any stale-candidate cleanup finish. A caller timeout returns on
schedule, but the lease remains reserved. The controller generation fence
rejects late adoption, then the retirement task disconnects a late successful
candidate before releasing its lease. A failed source needs no second
disconnect because the controller and transport failure paths already retire
it.

The manager cancels only the attempts it owns:

| Event | Attempts invalidated |
| --- | --- |
| Caller timeout | Exact lease |
| User scan cancellation | Early connects started by that scan |
| USB attach | Automatic machine attempt |
| Adapter unavailable | BLE attempts |
| Explicit disconnect | Matching device role |
| Shutdown | All active attempts |

Direct controller connects disarm the existing upper `ScaleWatch` before a
BLE transport can stop the native scan. A connect started by `ScaleWatch`
keeps its generation so a failed attempt can rearm the watch. No second watch
pause mechanism or app-wide BLE scheduler was added.

The discovery service no longer wraps `device.onConnect()` in a shorter Dart
`Future.timeout`. Native transport connect calls already have bounded
deadlines. Decaid still retries one `BleConnectException`; admission waits do
not consume that retry.

## Dependency gate

Decaid remains pinned to published `universal_ble`
`16bbfbce197eb5913c6b16578363f7dc943e605d`. The required reviewed tree ends at
local commit `546d55bbaef7f750c570b88d8c797299fc01335a`, which is not available from
`https://github.com/tadelv/universal_ble.git`. Hand-editing `pubspec.lock` or
pinning the uncorrected PR head would leave the build unreproducible or retain
the late `STATE_CONNECTED` teardown bug. Publication authorization is the
remaining pin gate. The `flutter_js` pin stays unchanged.

## Software evidence

- `ConnectionManager` and USB attach suites: 212 tests passed.
- Discovery, DE1 generation, and scale generation suites: 59 tests passed.
- `flutter analyze --no-pub`: no issues.
- Full Flutter suite: 4,268 tests passed with one existing skip.
- Android debug build: attempted with
  `flutter build apk --debug --no-pub --dart-define=simulate=1`; Gradle failed
  before project configuration with
  `java.io.IOException: Unable to establish loopback connection`.

## Hardware evidence

Android 10/Teclast, DE1, and original full-height scale tests are `NOT RUN`.
Part 5 (#877) owns the fixed A/B matrix. These software results do not close
#871, #875, or #877.
