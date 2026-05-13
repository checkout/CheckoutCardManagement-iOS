# SDK Lifecycle Policy

This document defines the lifecycle support policy for the Checkout Issuing SDK. It applies identically across all platforms (iOS and Android). Each platform maintains its own version numbers and release cadence, but the lifecycle rules described here are the same.

## Support Tiers

| **Tier** | **Definition** |
| --- | --- |
| **Full Support** | Active development, bug fixes, security patches, and new features. |
| **Advisory** | No patches are released. Security advisories direct clients to upgrade to a fully supported version. |
| **End of Life (EOL)** | No communication and no support of any kind. |

## Support Windows

When a new SDK version is released, the previous version's support window begins counting down after a **2-week grace period** from the release date. This grace period accounts for discovery lag and internal release processes.

| **Version Type** | **Full Support Duration** | **Advisory Duration** |
| --- | --- | --- |
| **Patch (e.g., 4.1.0 after 4.1.1 is released)** | 1 month | Until the next major version is released |
| **Minor (e.g., 4.1.x after 4.2.0 is released)** | 3 months | Until the next major version is released |
| **Major (e.g., 4.x after 5.0.0 is released)** | 9 months | Until the next major version is released, then EOL |

### How the Clock Works

1. A new version is released (e.g., 4.2.0 on _January 1st_).
2. A 2-week grace period begins — the old version (4.1.x) remains fully supported.
3. After the grace period (_January 15th_), the full support countdown starts.
4. For a minor version, full support lasts 3 months (until _April 15th_).
5. After full support ends, the old version enters the advisory tier until the next major release.

## Security Patches

* Security patches are applied to the **latest version only**. There is no backporting to older versions.
* Versions in the advisory tier receive **security advisories** recommending an upgrade but do not receive patches.
* **Break Glass:** In exceptional cases involving critical security vulnerabilities (e.g., **CVSS score 9.0+**), we will backport patches to a version in the Advisory tier at our discretion. This is reserved for instances where a major version migration is not immediately feasible for the client base and the risk is deemed critical.

## Platform Version Coupling

Changes to minimum platform requirements only occur in **major SDK versions**:

* **iOS: Minimum deployment target changes (e.g., dropping iOS 15)**
* **Android: minSdk or compileSdk changes (e.g., raising minSdk from 24 to 26)**

This ensures clients have the full 9-month major version migration window to accommodate platform requirement changes.

## Mandate Specific Releases

If there is a mandate from either the Schemes or Operating Systems that we will need to support, we will evaluate whether it is a minor or major change. Regardless of this, the aim will be to alert our clients 3 months ahead of time.

## Deprecation Strategy

APIs are deprecated before removal using a two-phase approach:

1. **Deprecate in a minor release** — the API is marked deprecated with migration hints using each platform's native mechanism. The deprecated API continues to function normally.
2. **Remove in the next major release** — the deprecated API is removed.

This gives clients compiler warnings well in advance of breaking changes, allowing them to plan migrations during the minor version support window.

### Platform-Specific Deprecation Mechanisms

* iOS (Swift): `@available(*, deprecated, renamed:)` or `@available(*, deprecated, message:)`
* Android (Kotlin/Java): `@Deprecated` with `ReplaceWith` annotation

## Migration Guides

Each major version release includes a detailed migration guide covering:

* All breaking changes with before/after code examples
* Deprecated API removals (previously warned via compiler deprecations)
* New minimum platform requirements
* Step-by-step migration instructions

## Versioning

All SDK components within a platform are versioned and released together as a bundle. The SDK follows [Semantic Versioning](https://semver.org/):

* **MAJOR — incompatible API changes**
* **MINOR — new functionality in a backwards-compatible manner**
* **PATCH — backwards-compatible bug fixes**

## Applicability

This policy applies starting from the next release on each platform. Versions released before this policy was adopted do not have defined support windows.

## Support Matrix

See [SUPPORT_MATRIX.md](SUPPORT_MATRIX.md) for the current support status of each SDK version by platform.

## Client Communication

* Clients are notified via **direct email** when a new version is released and when their current version is approaching end of full support.
* Release notes are published via **GitHub Releases** for each version.
* Changes are documented in each platform's **CHANGELOG.md**.
