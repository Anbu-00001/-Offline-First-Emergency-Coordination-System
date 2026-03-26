# FOSS Compliance Audit Report — OpenRescue

**Date:** 2026-03-26  
**Status:** COMPLIANT  
**Auditor:** Antigravity (AI Assistant)

## Executive Summary
OpenRescue has undergone a comprehensive dependency and source code audit to ensure 100% compliance with Free and Open-Source Software (FOSS) principles. No proprietary SDKs, closed APIs, or telemetry services were found in the current codebase.

## Dependency Classification

### 1. Mobile Application (`mobile_app/pubspec.yaml`)
| Dependency | License | Class | Status |
| --- | --- | --- | --- |
| flutter | BSD | FOSS | OK |
| flutter_map | BSD | FOSS | OK |
| drift | MIT | FOSS | OK |
| http / dio | BSD/MIT | FOSS | OK |
| libp2p bridge | MIT | FOSS | OK |
| location | MIT | FOSS | OK |

**Note:** Google Maps SDK and Firebase were checked and are NOT present.

### 2. Backend (`backend/requirements.txt`)
| Dependency | License | Class | Status |
| --- | --- | --- | --- |
| FastAPI | MIT | FOSS | OK |
| SQLAlchemy | MIT | FOSS | OK |
| GeoAlchemy2 | MIT | FOSS | OK |
| Zeroconf | LGPLv2 | FOSS | OK |

### 3. P2P Node (`backend/p2p-node/go.mod`)
| Dependency | License | Class | Status |
| --- | --- | --- | --- |
| go-libp2p | MIT/Apache2 | FOSS | OK |
| gossipsub | MIT/Apache2 | FOSS | OK |

## Compliance Checklists

### Mapping & Geolocation
- [x] **Map Tiles:** Using OpenStreetMap (OSM) via `flutter_map`.
- [x] **Routing:** Local OSRM instance (self-hosted Docker).
- [x] **Geocoding:** Nominatim (OSM) with mandatory User-Agent and rate-limiting.
- [x] **Attribution:** "© OpenStreetMap contributors" prominently displayed in UI.

### Privacy & Security
- [x] **Telemetry:** No analytics, crashlytics, or tracking found.
- [x] **Data Sovereignty:** No user data leaves the device/P2P network to 3rd-party servers.
- [x] **Secrets:** No API keys or credentials committed to the repository.

### Licensing
- [x] **Root License:** GPL-3.0.
- [x] **NOTICE file:** Created with required attributions.

## Replacements Made
| Proprietary Candidate | FOSS Replacement | Status |
| --- | --- | --- |
| Google Maps SDK | flutter_map + OSM | Fully Replaced |
| Google Geocoding API | Nominatim (OSM) | Fully Replaced |
| Firebase / Firestore | libp2p + GossipSub + Drift | Fully Replaced |
| Google Analytics | None (Removed) | Fully Replaced |

## Final Conclusion
The OpenRescue project is **100% FOSS compliant**. It maintains full architectural sovereignty and is suitable for deployment in offline or restricted environments without vendor lock-in.
