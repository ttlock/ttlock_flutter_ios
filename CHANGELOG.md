## 0.0.3

* iOS on-premise platform implementation wiring Pigeon Host APIs to CocoaPods `TTLockOnPremise` / `TTLockDFUOnPremise`.
* Implements `TTUpgradeHostApi` and upgrade streams; lock/gateway package DFU plus water meter / electric meter / keypad package DFU on this branch (network DFU not available via premise `TTDeviceDFU`).
* Upgrade abort is subscription cancel (`onCancel`) only; no explicit `stop*` APIs.
* Fixes second listener on the same channel tearing down the first upgrade session.
* Documents On-Premise Pod setup and differences vs the online `main` branch.
* Points parent-plugin docs at `ttlock_flutter_plus`.
