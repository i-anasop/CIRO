<div align="center">
  <img src="assets/logo.png" alt="CIRO Logo" width="180"/>
  <h1>CIRO: Crisis Intelligence & Response Orchestrator</h1>
  <p><strong>Next-Generation Emergency Management & Field Operations Dashboard</strong></p>
  
  [![Flutter Web](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
</div>

<br/>

## 🌐 Overview

**CIRO** (Crisis Intelligence & Response Orchestrator) is a production-grade, multi-platform emergency management dashboard. Built with Flutter, CIRO empowers field operators, dispatchers, and crisis managers with real-time intelligence, scenario simulation, and dynamic routing capabilities during critical incidents. 

The application is engineered with a "Cyber-Pastel" aesthetic, prioritizing visual clarity, high-contrast critical alerts, and seamless operator UX.

---

## ⚡ Core Features

- **🌍 Interactive Crisis Mapping**
  - Live spatial visualization of critical incidents.
  - Multi-agent scenario routing and real-time geographical analytics.
- **🚨 Intelligent Reporting System**
  - Streamlined incident logging with category-specific protocols (Flooding, Fire, Grid Failures, etc.).
  - Automated threat categorization and payload generation.
- **🛡️ Scenario Simulation Engine (`ScenarioEngine`)**
  - Built-in `Demo Mode` to simulate complex multi-variable crisis scenarios without affecting production systems.
  - Generates AI-driven incident reports and situational variables.
- **⚙️ Operator Command Center**
  - Highly customizable operator profiles.
  - Dynamic UI state management adapting to alert severity levels.
  - Regional configuration, localization, and offline protocol caching.

---

## 🛠️ Technology Stack

- **Framework:** Flutter (Optimized for Web & Mobile)
- **State Management:** Provider / ListenableBuilder Architecture
- **Routing:** GoRouter (Declarative Web-Safe Routing)
- **Mapping:** Google Maps API (via `google_maps_flutter`)
- **External Pipelines (Pending/Mocked):** OpenWeather API, News API

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.19.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- A modern web browser (Chrome recommended for optimal rendering).

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/i-anasop/CIRO.git
   cd CIRO
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the root directory and add your API keys:
   ```env
   GOOGLE_MAPS_API_KEY=your_google_maps_key
   OPENWEATHER_API_KEY=your_openweather_key
   NEWS_API_KEY=your_news_api_key
   ```

4. **Run the application (Web target recommended):**
   ```bash
   flutter run -d chrome
   ```

---

## 🏗️ Project Architecture

```text
lib/
├── agents/        # AI orchestration and simulated pipeline logic
├── components/    # Reusable UI widgets (Cards, Sheets, Badges)
├── data/          # Mock data structures and initial states
├── models/        # Core entity data classes (Crisis, Signal, Report)
├── navigation/    # GoRouter configuration and route definitions
├── screens/       # Main top-level UI views
├── services/      # Singleton services (State, APIs, Location, Mocking)
├── theme/         # Design tokens, typography, and color systems
└── utils/         # Helper functions and cross-platform stubs
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to check the [issues page](https://github.com/i-anasop/CIRO/issues) for active bounties or open discussions.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

<div align="center">
  <p>Engineered for Resilience. Built for Response.</p>
</div>
