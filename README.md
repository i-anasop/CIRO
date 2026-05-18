<div align="center">
  <img src="assets/logo.png" alt="CIRO Logo" width="180"/>
  <h1>Crisis Intelligence & Response Orchestrator (CIRO)</h1>
  <p><strong>Enterprise-Grade Emergency Management & Field Operations Dashboard</strong></p>
  
  [![Flutter Web](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
</div>

<br/>

## 1. Overview

**CIRO** is a highly resilient, multi-platform emergency management dashboard. Built to serve field operators, dispatchers, and crisis management directors, CIRO delivers real-time intelligence aggregation, complex scenario simulation, and dynamic routing capabilities during critical incidents. 

The architecture is designed to support high-contrast visual clarity, strictly prioritizing rapid information consumption and seamless operator user experience under high-stress conditions.

---

## 2. Core Capabilities

- **Interactive Crisis Mapping**
  - Live spatial visualization of critical incident perimeters.
  - Multi-agent scenario routing and real-time geographical analytics using Google Maps infrastructure.
- **Intelligent Reporting Protocols**
  - Streamlined, standardized incident logging with category-specific data structures (e.g., Hydrological, Fire, Grid Failures).
  - Automated threat categorization and standardized payload generation for backend processing.
- **Scenario Simulation Engine (`ScenarioEngine`)**
  - Integrated deterministic mock environments to simulate complex, multi-variable crisis events without impacting production networks.
  - Programmatic generation of synthetic incident reports and situational variables for operator training.
- **Operator Command Center**
  - Role-based customizable operator profiles and authentication workflows.
  - Dynamic UI state management adapting fluidly to escalating alert severity levels.
  - Configurable regional localization, privacy controls, and offline protocol caching.

---

## 3. Technology Stack

- **Application Framework:** Flutter SDK (Optimized for Web & Mobile targets)
- **Language:** Dart 3.0+
- **State Management Architecture:** Provider / Native ListenableBuilder
- **Routing Infrastructure:** GoRouter (Declarative, Deep-Linkable Web Routing)
- **Geospatial Mapping:** Google Maps API (`google_maps_flutter`)
- **External Data Pipelines:** OpenWeather API, News API (Integration ready)

---

## 4. System Requirements & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- A modern, Chromium-based web browser for optimal rendering.

### Build Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/i-anasop/CIRO.git
   cd CIRO
   ```

2. **Resolve dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   A `.env` file must be provisioned in the root directory prior to compilation.
   ```env
   GOOGLE_MAPS_API_KEY=your_google_maps_key
   OPENWEATHER_API_KEY=your_openweather_key
   NEWS_API_KEY=your_news_api_key
   ```

4. **Execute the application:**
   ```bash
   flutter run -d chrome
   ```

---

## 5. Directory Structure & Architecture

```text
lib/
├── agents/        # Algorithmic orchestration and simulated pipeline logic
├── components/    # Reusable, standardized UI widget primitives
├── data/          # Mock data structures and initial application states
├── models/        # Core entity data classes and serialization logic
├── navigation/    # GoRouter configuration and declarative route definitions
├── screens/       # Top-level view controllers
├── services/      # Singleton service layer (State, APIs, Location, Telemetry)
├── theme/         # Centralized design tokens, typography, and color systems
└── utils/         # Helper functions and cross-platform compilation stubs
```

---

## 6. Contribution Guidelines

We adhere to a strict branching model and code review policy. To contribute:

1. Fork the repository.
2. Check out a dedicated feature branch (`git checkout -b feature/issue-id-description`).
3. Commit your changes following standard conventional commits.
4. Push the branch (`git push origin feature/issue-id-description`).
5. Open a Pull Request detailing architectural changes and testing procedures.

---

## 7. License

Distributed under the MIT License. See `LICENSE` for further details.
