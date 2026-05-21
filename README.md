<div align="center">

<img src="assets/logo.png" alt="CIRO Logo" width="200" />

<br />

<img src="https://img.shields.io/badge/CIRO-Crisis%20Intelligence%20%26%20Response%20Orchestrator-C8836A?style=for-the-badge&labelColor=0D0D0D&color=C8836A" alt="CIRO" />

# CIRO
### Crisis Intelligence & Response Orchestrator

**Mobile-first agentic crisis response — signal fusion, severity prediction, resource allocation, and impact simulation in one command center.**

<br />

[![Flutter](https://img.shields.io/badge/Flutter-Mobile%20%2B%20Web-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Groq](https://img.shields.io/badge/AI-Groq%20%2F%20LLaMA%203.3-F97316?style=flat-square&logo=lightning&logoColor=white)](https://groq.com)
[![Google Maps](https://img.shields.io/badge/Maps-Google%20Maps-4285F4?style=flat-square&logo=googlemaps&logoColor=white)](https://developers.google.com/maps)
[![OpenWeather](https://img.shields.io/badge/Weather-OpenWeather-EB6E4B?style=flat-square&logo=openweathermap&logoColor=white)](https://openweathermap.org)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-A78BFA?style=flat-square&logo=android&logoColor=white)]()
[![Status](https://img.shields.io/badge/Status-Demo%20Ready-22C55E?style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-white?style=flat-square)](LICENSE)

---

> 🏆 **Google Antigravity Hackathon — Challenge 3: Crisis Intelligence & Response Orchestrator**
> Built to demonstrate how agentic systems can move cities from reactive crisis response to coordinated situational intelligence.

---

[Overview](#overview) · [Capabilities](#core-capabilities) · [Architecture](#architecture) · [Stack](#technology-stack) · [Setup](#setup) · [Demo](#demo-script) · [Roadmap](#roadmap)

</div>

---

## Overview

Cities rarely receive crisis information through a single clean channel. A flood surfaces first as a social post — then a weather alert — then a traffic disruption — while a field report contradicts the original signal entirely.

**CIRO is built for that reality.** It ingests fragmented multi-source signals, classifies emerging incidents, predicts severity, allocates constrained resources, simulates response outcomes, and explains every decision in a human-readable command center — designed for laypeople and responders, not just technical operators.

---

## Core Capabilities

| Capability | Description |
|---|---|
| **Multi-Signal Fusion** | Ingests social/citizen reports, weather, traffic, sensors, field reports, and emergency proxies |
| **Crisis Classification** | Detects urban flooding, heatwave, accident, road blockage, power outage, and monitoring states |
| **Severity Prediction** | Estimates severity, confidence, affected population, duration, spread risk, and peak impact |
| **Resource Allocation** | Optimizes dispatch of ambulances, rescue teams, police, shelters, pumps, and generators |
| **Impact Simulation** | Before/after metrics for response time, congestion, resource cost, and side effects |
| **Stakeholder Messaging** | Tailored communications for public, emergency services, hospitals, utilities, and transport |
| **False Signal Recovery** | Handles false positives, false negatives, stale APIs, and conflicting sources gracefully |
| **Antigravity Traces** | Structured orchestration traces for full auditability and judge review |

---

## Architecture

```
Signal Layer              Agent Pipeline                 Output Layer
──────────────────        ───────────────────────        ──────────────────────────
Social / Citizens    →    Credibility Scoring       →    Command Center UI
Weather                   Crisis Classification          Crisis Detail View
Traffic / Routes          Severity Prediction            Response Plan
Mock Sensors              Resource Optimization          Impact Simulation
Field Reports             Stakeholder Messaging          Antigravity Traces
Emergency Proxies         False-Signal Recovery          Notification Inbox
```

**Design Principles**
- **Mock-first, real-ready** — deterministic demos ship reliably; live signals layer on top
- **Typed pipeline outputs** — every stage produces structured data, no ad hoc UI strings
- **Graceful degradation** — missing APIs become labeled warnings, not crashes
- **Explainability by design** — every agent decision has a plain-language counterpart

---

## Technology Stack

### App

| Layer | Technology |
|---|---|
| Framework | Flutter — Mobile + Web |
| Language | Dart `^3.10.8` |
| Routing | `go_router` |
| State | Singleton services · `ListenableBuilder` |
| Storage | `shared_preferences` · `flutter_dotenv` |
| Auth | Google Sign-In · local profile persistence |
| Notifications | `flutter_local_notifications` |

### AI & Data

| Source | Role |
|---|---|
| Groq API · `llama-3.3-70b-versatile` | Crisis classification, response planning, simulation, stakeholder comms |
| Google Maps · `google_maps_flutter` | Interactive maps, traffic-aware routing |
| OpenWeather | Live weather risk — rainfall, heat, humidity, wind |
| NewsAPI · GNews · ReliefWeb | Crisis-relevant public signal enrichment |
| X API | Recent official-handle posts (NDMA, police, transport, highway authorities) |

---

## Demo Modes

**Demo Mode** — Primary judging path. Deterministic, fully offline, built around curated G-10 Islamabad scenarios. Use this for video recording and judge presentations. No API keys required.

**Real Mode** — Uses device GPS and live API signals. Gracefully degrades when keys are absent; every missing service becomes a labeled fallback rather than a failure. Groq enables the full AI agent pipeline; other APIs expand live signal coverage progressively.

---

## Setup

**Prerequisites:** Flutter SDK (Dart `^3.10.8`) · Chrome · Android Studio or Xcode

```bash
flutter pub get
```

Create `.env` in the project root:

```env
GOOGLE_MAPS_API_KEY=your_key
OPENWEATHER_API_KEY=your_key
NEWS_API_KEY=your_key
GNEWS_API_KEY=your_key
GROQ_API_KEY=your_key
X_BEARER_TOKEN=your_token
```

> All keys are optional. Demo Mode is fully functional with zero configuration.

```bash
# Development
flutter run -d chrome          # Web
flutter run -d android         # Android

# Production
flutter build web
flutter build apk --release
```

---

## Testing

```bash
flutter analyze    # Static analysis
flutter test       # Unit & widget tests
```

Automated coverage includes: scenario initialization · all five verification states · multi-crisis coordination · resource trade-off generation · Antigravity trace output · degraded fallback baseline · Real Mode adapter conversion.

---

## Demo Script

| Step | Action |
|---|---|
| 1 | Launch → select **Demo Mode: G-10 Islamabad** |
| 2 | Command Center — active crisis, signal cards, map, crisis feed |
| 3 | Crisis Details — affected area, confidence, peak impact, people at risk |
| 4 | Tap **Why?** — plain-language source agreement and confidence explanation |
| 5 | Response Plan — tactical dispatch timeline and expected steps |
| 6 | Expected Impact — before/after simulated outcomes |
| 7 | Switch to simultaneous flood + heatwave — multi-crisis trade-offs |
| 8 | False positive recovery scenario — alert retraction and correction path |
| 9 | Note structured Antigravity trace events generated beneath the UI |

---

## Roadmap

- [ ] Streaming adapters for social, weather, traffic, IoT sensors, and hospital capacity
- [ ] Server-side resource optimization with agency-specific inventory and travel-time constraints
- [ ] Immutable incident audit store for Antigravity traces
- [ ] Operator approval queues for public alerts and alert retractions
- [ ] Real GIS flood plains, road graphs, and urban vulnerability maps
- [ ] Role-based access for field teams, hospitals, utilities, and command centers
- [ ] Post-incident analytics and model calibration

---

## Limitations

CIRO is a hackathon prototype — not a replacement for official emergency services. Emergency calls, sensors, and field report feeds are simulated unless connected to real city infrastructure. Public alerts require human approval before any production deployment. Antigravity traces are prototype orchestration artifacts, not certified incident-command records.

---

<div align="center">

<br />

<img src="assets/logo.png" alt="CIRO" width="72" />

<br /><br />

### CIRO

*Detect. Decide. Respond.*

<br />

---

<br />

<img src="https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg" height="28" alt="Google" />

### Antigravity Hackathon

**Challenge 3 — Crisis Intelligence & Response Orchestrator**

<br />

*CIRO was built for the Google Antigravity Hackathon to demonstrate how agentic systems*
*can help cities move from reactive crisis response to coordinated situational intelligence.*

<br />

[![Google Antigravity Hackathon](https://img.shields.io/badge/Google%20Antigravity-Hackathon-4285F4?style=for-the-badge&logo=google&logoColor=white&labelColor=0f0f0f)]()
[![Challenge 3](https://img.shields.io/badge/Challenge%203-Crisis%20Intelligence-C8836A?style=for-the-badge&labelColor=0f0f0f)]()

<br />

</div>
