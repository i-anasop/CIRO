# CIRO — Real Mode Setup Guide

> This document explains how to configure CIRO's Real Mode for live data collection.
> Demo Mode always remains available and does not require any of these steps.

---

## Overview

CIRO supports two operating modes:

| Mode | Data Source | Requirements |
|---|---|---|
| **Demo Mode** | Local mock scenarios | None — works offline |
| **Real Mode** | Live GPS, weather, news, traffic | API keys in `.env` |

---

## Step 1 — Create Your `.env` File

Copy `.env.example` to `.env` in the project root:

```bash
cp .env.example .env
```

Then fill in your actual API keys:

```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
OPENWEATHER_API_KEY=your_openweathermap_api_key_here
NEWS_API_KEY=your_newsapi_key_here
```

> ⚠️ **NEVER commit `.env` to version control.** It is already in `.gitignore`.

---

## Step 2 — Obtain API Keys

### Google APIs (Single Project)

All Google services use the **same API key** from Google Cloud Console.

1. Go to: https://console.cloud.google.com/
2. Create or select a project
3. Enable these APIs under **APIs & Services → Library**:
   - **Maps SDK for Android** (for native map rendering)
   - **Geocoding API** (reverse geocode GPS → address)
   - **Places API (New)** (future: POI enrichment)
   - **Routes API** (traffic-aware routing)
4. Go to **APIs & Services → Credentials**
5. Click **Create Credentials → API Key**
6. Restrict the key to the above 4 APIs (recommended)
7. Copy the key to `GOOGLE_MAPS_API_KEY` in `.env`

### OpenWeather API

Used for: current temperature, humidity, rainfall, crisis risk detection

1. Go to: https://openweathermap.org/api
2. Register a free account
3. Go to **Profile → My API Keys**
4. Copy the default key (or create a new one)
5. Paste into `OPENWEATHER_API_KEY` in `.env`
6. Free tier includes **Current Weather API** (used by CIRO) — no payment needed

### NewsAPI

Used for: crisis-relevant news signal detection near the detected location

1. Go to: https://newsapi.org/
2. Register a free developer account
3. Go to your dashboard → copy the API key
4. Paste into `NEWS_API_KEY` in `.env`
5. Free tier: 100 requests/day, developer use only

> ⚠️ **NewsAPI free tier blocks browser (CORS) requests.**
> CIRO uses the API from Flutter's HTTP layer (not browser), so it works fine
> on Android, iOS, and desktop. On **web builds**, NewsAPI calls will fail —
> this is expected and gracefully handled.

---

## Step 3 — Run the App

```bash
# Install packages (only needed once or after pubspec changes)
flutter pub get

# Run on Android device/emulator
flutter run

# Run on web (Demo Mode fully works; Real Mode limited by CORS on NewsAPI)
flutter run -d chrome

# Build web (debug)
flutter build web --debug --no-wasm-dry-run
```

---

## Step 4 — Switch Between Modes

1. Open the app → tap **Settings** in the bottom navigation
2. Under **Operating Mode**, toggle **Demo Mode** ON/OFF
3. The **API Key Readiness** checklist shows which services are configured
4. Tap **Test Real Services** to verify connectivity

---

## Step 5 — Test Real Mode

1. Switch Demo Mode **OFF** in Settings
2. Go to **Dashboard** → scroll to the bottom
3. Tap **Analyze Real Situation**
4. The app will:
   - Request GPS permission (Android/iOS only)
   - Reverse geocode your position via Google Geocoding API
   - Fetch current weather from OpenWeather
   - Search crisis news via NewsAPI
   - Estimate local traffic via Google Routes API
5. Results show in the Real Mode preview card

If a service fails:
- A SnackBar shows which service had an error
- The card displays partial results from working services
- The app never crashes — always falls back gracefully

---

## Architecture

```
.env (secrets)
  │
  ▼
AppConfig (singleton, dotenv loader)
  │
  ▼
RealSignalService (coordinator)
  ├── LocationService      → geolocator (GPS)
  ├── GeocodingService     → Google Geocoding API
  ├── WeatherService       → OpenWeather API
  ├── NewsSignalService    → NewsAPI
  └── RoutesService        → Google Routes API
                │
                ▼
         RealSignalBundle (typed output)
                │
                ▼
        Dashboard Real Mode Card
```

---

## Known Limitations

| Limitation | Details |
|---|---|
| **NewsAPI CORS** | Free tier blocks browser. Works on Android/iOS/desktop. |
| **GPS on Web** | Geolocator has limited web support — may fall back to mock coords |
| **Routes API quota** | Free tier: 10,000 requests/month. CIRO requests 1 per analyze |
| **OpenWeather free** | Forecast API requires paid plan. CIRO uses Current Weather (free) |
| **External data gaps** | Real Mode now feeds live and cached signals into the 9-agent pipeline, but sparse APIs, missing keys, or rate limits may still reduce confidence. CIRO labels cached, derived, and fallback signals instead of hiding degraded sources. |

---

## Next Recommended Step

Harden the real signal loop with scheduled background refresh:

```
RealSignalService.fetchAll()
  → SignalCacheService.cacheBundle(bundle)
  → RealScenarioAdapter.fromBundle(bundle + cached city memory)
  → AgentPipeline / AiAgentPipeline
  → ranked crisis feed + active crisis response
```

Current implementation note: `RealSignalBundle` is now cached through
`SignalCacheService`, adapted by `RealScenarioAdapter`, and consumed by the
local or Groq-powered agent pipeline. The feed is ranked by severity,
confidence, source strength, and freshness.

---

*Last updated: 2026-05-21 | Version: 1.2.0 | Status: Real Mode Agent Pipeline + Signal Cache Active*
