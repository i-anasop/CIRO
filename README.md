<div align="center">
  <br />
  <img src="assets/logo.png" alt="CIRO" width="120" />
  <br /><br />

  <h1>CIRO</h1>
  <p><strong>Crisis Intelligence &amp; Response Orchestrator</strong></p>
  <p>
    A mobile-first agentic crisis response system built for the
    <strong>Google Antigravity Hackathon</strong>.
  </p>

  <br />

  ![Flutter](https://img.shields.io/badge/Flutter-Mobile%20%2B%20Web-02569B?style=flat-square&logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?style=flat-square&logo=dart&logoColor=white)
  ![Groq](https://img.shields.io/badge/AI-Groq%20%2F%20LLaMA%203.3-F97316?style=flat-square)
  ![Status](https://img.shields.io/badge/Status-Demo%20Ready-22C55E?style=flat-square)

  <br /><br />

  ---
</div>

## Overview

Cities rarely receive crisis information through a single clean channel. A flood may surface first as a social post, then a weather alert, then a traffic disruption — while a field report contradicts the original signal entirely. CIRO is designed around that messy reality.

It fuses fragmented signals, detects emerging incidents, predicts severity, allocates constrained resources, simulates response impact, and explains decisions — all inside a human-readable command center.

---

## Core Capabilities

| Capability | Description |
|---|---|
| **Multi-Signal Fusion** | Ingests social/citizen reports, weather, traffic, sensors, field reports, and emergency proxies |
| **Crisis Classification** | Detects urban flooding, heatwave, accident, road blockage, power outage, and monitoring states |
| **Severity Prediction** | Estimates severity, confidence, affected population, duration, spread risk, and peak impact |
| **Resource Allocation** | Optimizes dispatch of ambulances, rescue teams, police, shelters, pumps, and generators |
| **Impact Simulation** | Produces before/after metrics for response time, congestion, resource cost, and side effects |
| **Stakeholder Messaging** | Generates communications for the public, emergency services, hospitals, utilities, and transport |
| **Error Recovery** | Handles false positives, false negatives, stale APIs, and conflicting sources gracefully |
| **Antigravity Traces** | Generates structured orchestration traces for auditability and judging |

---

## Technology Stack

| Layer | Technology |
|---|---|
| Framework | Flutter — Mobile + Web |
| Language | Dart `^3.10.8` |
| AI Reasoning | Groq API · `llama-3.3-70b-versatile` |
| Maps & Routes | Google Maps · `google_maps_flutter` · `flutter_map` |
| Weather | OpenWeather |
| News Signals | NewsAPI · GNews · ReliefWeb (UN OCHA) |
| Social Signals | X API (official-handle search) |
| Location | `geolocator` · `permission_handler` |
| Auth | Google Sign-In · local profile persistence |
| State | Singleton services · `ListenableBuilder` |
| Storage | `shared_preferences` · `flutter_dotenv` |

---

## Demo Modes

**Demo Mode** — The primary judging path. Deterministic, fully offline, and built around curated G-10 Islamabad scenarios. Use this for hackathon video recording and judge presentations.

**Real Mode** — Uses device GPS and live API signals. Gracefully degrades when keys are unavailable; every missing service becomes a labeled fallback rather than a failure.

---

## Setup

**Prerequisites:** Flutter SDK (Dart `^3.10.8`), Chrome for web, Android Studio / Xcode for mobile.

```bash
flutter pub get
```

Create a `.env` file in the project root:

```env
GOOGLE_MAPS_API_KEY=your_key
OPENWEATHER_API_KEY=your_key
NEWS_API_KEY=your_key
GNEWS_API_KEY=your_key
GROQ_API_KEY=your_key
X_BEARER_TOKEN=your_token
```

> All keys are optional. Demo Mode works fully offline without any configuration.

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# Build
flutter build web
flutter build apk --release
```

---

## Testing

```bash
flutter analyze     # Static analysis
flutter test        # Unit & widget tests
```

Test coverage includes scenario initialization, verification states, multi-crisis coordination, resource trade-off generation, Antigravity trace output, degraded fallback, and Real Mode adapter conversion.

---

## Architecture Principles

- **Mock-first, real-ready** — Deterministic demos ship reliably; live signals layer on top.
- **Typed pipeline outputs** — No ad hoc UI strings; every stage produces structured data.
- **Graceful degradation** — Missing APIs produce warnings, not crashes.
- **Explainability by design** — Every agent decision has a corresponding plain-language explanation.
- **Mobile-first** — Designed for field operators and laypeople, not only technical users.

---

## Limitations

- Not a replacement for official emergency services — CIRO is a prototype.
- Emergency calls, sensors, and field report feeds are simulated unless connected to real city infrastructure.
- Public alerts require human approval before any production deployment.
- Antigravity traces are prototype orchestration artifacts, not certified incident-command records.

---

<div align="center">
  <sub>Built for the Google Antigravity Hackathon &nbsp;·&nbsp; Prototype — not for production emergency use</sub>
</div>
