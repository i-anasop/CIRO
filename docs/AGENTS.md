# AGENTS.md — CIRO Project Instructions

> **This file is the single source of truth for all development on this project.**
> Every agent, developer, and coding step must read and follow this document before making any changes.

---

## 1. Project Mission

**CIRO — Crisis Intelligence & Response Orchestrator** is a mobile-first agentic AI system designed to help cities detect, analyze, and respond to localized crises in real time.

Cities face a wide spectrum of emergencies — urban flooding, heatwaves, road blockages, accidents, infrastructure failures, public disorder, disease spikes, and power outages. These events generate signals scattered across social media, traffic maps, weather systems, citizen complaints, emergency calls, and field sensors. However, response systems are often fragmented, slow, and reactive.

CIRO acts as an intelligent crisis command center. It continuously collects signals from multiple sources, fuses and interprets them, detects emerging crises, assesses severity and confidence, prioritizes resources, plans coordinated responses, simulates outcomes, and presents everything through a clean professional interface — in real time.

CIRO does not replace human decision-makers. It empowers them with faster, better-organized intelligence and a clear action plan.

---

## 2. Product Goal

The goal of this project is a **complete, working, demo-ready prototype** — not a production system.

The prototype must:
- Be visually impressive and fully functional end-to-end.
- Demonstrate the full crisis intelligence workflow from signal collection to outcome simulation.
- Use mock data that is cleanly structured so real APIs can replace it later with minimal changes.
- Be stable enough for a live hackathon demo without crashes or dead screens.
- Communicate the value of the multi-agent AI approach clearly to a non-technical audience.

**Authentication / login is intentionally excluded from the MVP.** The app opens directly into the crisis experience. Login and user management can be added in a post-hackathon version.

---

## 3. Core Workflow

The following control flow is **mandatory** and must be preserved across all development iterations:

```
App Opens
  │
  ▼
Location Permission / Mock Location Selection
  │
  ▼
Signal Collection (multi-source)
  │
  ▼
Signal Fusion (combine + denoise)
  │
  ▼
Crisis Detection (classify type + extract location)
  │
  ▼
Severity Calculation (score, confidence, impact estimate)
  │
  ▼
Resource Prioritization (across active crises)
  │
  ▼
Response Planning (coordinated action plan)
  │
  ▼
Action Simulation (reroute, dispatch, alert, ticket)
  │
  ▼
Before / After Impact View (metrics comparison)
  │
  ▼
Agent Trace / Logs (reasoning audit trail)
  │
  ▼
User Report / Verify (human-in-the-loop feedback)
```

Every screen in the app must map to a step in this workflow. Do not build screens that exist outside this flow without a clear justification.

---

## 4. MVP Crisis Types

The prototype must support exactly these **five crisis types**:

| # | Crisis Type                          | Description                                              |
|---|--------------------------------------|----------------------------------------------------------|
| 1 | **Urban Flooding**                   | Waterlogging, road submersion, drainage failure          |
| 2 | **Road Blockage / Traffic Jam**      | Severe congestion, road closure, accident-caused block   |
| 3 | **Accident**                         | Vehicle collision, structural collapse, casualty reports |
| 4 | **Heatwave**                         | Extreme heat advisory, health risk zones                 |
| 5 | **Power Outage / Infrastructure Failure** | Grid failure, utility disruption, blackout zone     |

Each crisis type must have:
- A distinct severity badge style and color.
- A matching set of simulated response actions.
- Relevant before/after impact metrics.

---

## 5. Required Signal Sources

### Mandatory (MVP must include all three)

| Source            | Description                                              |
|-------------------|----------------------------------------------------------|
| **Social Posts**  | Citizen-written text posts (can be in Urdu or English)   |
| **Weather Alerts**| Official or system-generated weather advisories          |
| **Traffic Data**  | Congestion percentages, route status, blockage flags     |

### Optional (add if time permits)

- Citizen Reports (app-submitted forms)
- Emergency Calls (mock call transcripts)
- Mock Sensors (IoT readings: temperature, water level, power status)
- Field Reports (on-ground responder updates)

All signal sources must be implemented as **mock data modules** (`src/data/`) that can be swapped for real API calls in the future. Signal schemas must be consistent and typed.

---

## 6. Multi-Agent Architecture

CIRO uses a pipeline of specialized AI agents. Each agent has a single, well-defined responsibility. Agents must be implemented as modular services.

### Agent Definitions

| Agent                  | Responsibility                                                                 |
|------------------------|---------------------------------------------------------------------------------|
| **Signal Agent**       | Collects raw signals from all configured sources and normalizes them to a standard schema. |
| **Fusion Agent**       | Combines signals from multiple sources, removes noise, resolves conflicts, and builds a unified event picture. |
| **Detection Agent**    | Classifies the crisis type, extracts location, identifies affected area, and estimates time of onset. |
| **Severity Agent**     | Estimates severity score (Low / Moderate / High / Critical), confidence percentage, affected population count, expected duration, and likely escalation path. |
| **Resource Agent**     | Evaluates available resources (units, vehicles, personnel) and prioritizes them across concurrent active crises. |
| **Response Planner Agent** | Generates a coordinated, step-by-step action plan with assigned resources, priorities, and estimated timelines. |
| **Simulation Agent**   | Simulates the execution of each action: traffic rerouting, emergency dispatch, public alert broadcasts, emergency ticket creation, utility escalation, hospital preparation. |
| **Verification Agent** | Handles ambiguous cases — flags false positives, escalates false negatives, surfaces conflicting signals, and marks items requiring human review. |
| **Log Agent**          | Records every agent decision and reasoning summary in a human-readable, timestamped audit trail. |

### Agent Communication Rules

- Agents must be **stateless** where possible. Each agent receives input and returns a structured output.
- Agent outputs must be **typed objects** (define models in `src/models/`).
- Agent logic must live in `src/agents/`. Do not embed agent logic inside UI components or screens.
- All agent logs must flow through the **Log Agent** — never log directly to console in production flows.

---

## 7. Main Screens

The app must eventually include the following screens. Build them in order of priority.

| # | Screen                             | Priority | Description                                              |
|---|------------------------------------|----------|----------------------------------------------------------|
| 1 | **Splash Screen**                  | P1       | App identity, logo, brief tagline, auto-advance          |
| 2 | **Location Permission / Mock Location** | P1  | Request location or select a mock city/zone              |
| 3 | **Home Crisis Dashboard**          | P1       | Active crises list, severity badges, status summary      |
| 4 | **Crisis Detail Screen**           | P1       | Full signal breakdown, detection reasoning, severity     |
| 5 | **Response Plan Screen**           | P1       | Ordered action plan, assigned resources, timeline        |
| 6 | **Simulation / Before vs After**   | P1       | Side-by-side metrics, animated transitions               |
| 7 | **Agent Logs Screen**              | P1       | Timestamped agent trace, decision summaries              |
| 8 | **Map / Affected Area Screen**     | P2       | Visual map overlay with crisis zones                     |
| 9 | **Reports Screen**                 | P2       | User-submitted and field reports                         |
| 10| **Demo Scenarios Screen**          | P2       | One-tap preloaded demo scenarios for presentation        |
| 11| **Profile / Settings Screen**      | P3       | App settings, theme toggle, mock data controls           |

---

## 8. UI/UX Direction

CIRO must look and feel like a **premium emergency operations platform**.

### Design Principles

- **Dark mode first.** Light mode is optional and lower priority.
- **Clean information hierarchy.** The most critical crisis information must be immediately visible.
- **Strong typography.** Use a professional sans-serif font (e.g., Inter, Outfit, or Space Grotesk).
- **Severity-coded color system:**
  - 🔴 Critical — deep red / `#D32F2F`
  - 🟠 High — amber / `#F57C00`
  - 🟡 Moderate — yellow / `#FBC02D`
  - 🟢 Low — teal green / `#388E3C`
  - ⚪ Unknown / Pending — muted gray
- **Cards over tables.** Use card-based layouts with clear labels, not data tables.
- **Status badges.** Every crisis must display a severity badge, confidence percentage, and status tag (Active / Monitoring / Resolved / Needs Verification).
- **Timeline logs.** Agent trace/logs must be presented as a vertical timeline, not raw text.
- **Before/After metrics.** Use a side-by-side panel with delta indicators (arrows, percentages, color changes).
- **Map-style panels.** Use placeholder map views or map-inspired visual panels for location data.
- **Smooth transitions.** Screen transitions and data loading must feel fluid, not abrupt.
- **No clutter.** Every element on screen must serve a purpose. Remove anything decorative that adds noise.
- **No childish or consumer-app colors.** This is an emergency-tech product. The palette must reflect urgency, professionalism, and trust.

### Anti-Patterns to Avoid

- Bright backgrounds with light text.
- Generic emoji or cartoon icons in primary UI.
- Unformatted JSON or raw data dumps shown directly in the UI.
- Modals that block the full screen without dismiss options.
- Navigation that breaks the linear workflow without offering a way back.

---

## 9. Data Strategy

### Principles

1. **Mock data first.** All data used in the MVP must come from local mock files.
2. **Real-API ready.** Mock data structures must match the expected shape of real API responses so that swapping is a one-file change.
3. **No real sensitive data.** Do not use real personal information, real emergency records, or any live external data in the prototype.
4. **Typed schemas.** Define data models in `src/models/` for all entities: `Signal`, `Crisis`, `Resource`, `ActionPlan`, `SimulationResult`, `AgentLog`.

### Mock Data Location

All mock data files belong in:
```
src/data/
  mockSignals.js        # Raw signals from all sources
  mockCrises.js         # Pre-detected crisis scenarios
  mockResources.js      # Available response resources
  mockActionPlans.js    # Pre-built response plans
  mockSimulations.js    # Before/after simulation results
  mockAgentLogs.js      # Agent decision logs
  mockDemoScenarios.js  # Full end-to-end demo scenarios
```

---

## 10. Simulation Requirements

The simulation step must demonstrate tangible, visible change between "before" and "after" executing the response plan.

### Actions to Simulate

| Action                    | Example Output                                     |
|---------------------------|----------------------------------------------------|
| Traffic Rerouting         | Congestion % drops, alternate routes activated     |
| Emergency Dispatch        | Units assigned, ETA shown, status updated          |
| Public Alert Broadcast    | Alert message shown, recipient count displayed     |
| Emergency Ticket Creation | Ticket ID generated, department notified           |
| Utility Escalation        | Escalation path shown, estimated restoration time  |
| Hospital Preparation      | Beds allocated, trauma team alerted (where relevant)|
| System Status Update      | Infrastructure status changed (e.g., Road: Closed → Managed) |

### Before / After Metrics Panel

Every simulation must show a before/after comparison for:

| Metric                  | Before   | After    | Delta  |
|-------------------------|----------|----------|--------|
| Congestion %            | 88%      | 52%      | ▼ 36%  |
| Response Time (est.)    | 18 min   | 7 min    | ▼ 11m  |
| Risk Level              | Critical | Moderate | ▼ 2    |
| Affected People         | 3,200    | 850      | ▼ 2,350|
| Resources Dispatched    | 0        | 6 units  | ▲ 6    |
| Alerts Sent             | 0        | 4,800    | ▲ 4,800|

---

## 11. False Signal Handling

CIRO must demonstrate intelligent handling of uncertain or conflicting information. The **Verification Agent** must surface five distinct signal states:

| State                       | Description                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| ✅ **Confirmed Crisis**      | High-confidence signals from multiple sources agree. Proceed with response. |
| ⚠️ **Needs Verification**   | Conflicting or low-confidence signals. Flag for human review before escalating. |
| ⚡ **Conflicting Signals**   | Sources disagree (e.g., social posts say flooding, traffic data shows clear). Surface the conflict. |
| 🔴 **False Positive Recovery** | System previously detected a crisis that did not materialize. Log the recovery and update confidence model. |
| 🔼 **False Negative Escalation** | A crisis was initially missed or under-rated. Escalate severity and notify. |

All five states must be demonstrable within the prototype — at minimum through the Demo Scenarios screen.

---

## 12. Coding Rules

These rules are **mandatory** for every development step. No exceptions without a documented reason.

### Stability Rules
- ❌ **Do not remove existing working features** while adding new ones.
- ❌ **Do not leave dead screens.** Every screen must either be functional or show a clear "Coming Soon / Demo Mode" state.
- ❌ **Do not create hard-to-debug backend dependencies** in the MVP. Keep everything local and mock-driven.
- ✅ **Every button shown in the UI must either work or display a clear demo/coming-soon state.**
- ✅ **Prioritize demo stability over feature completeness.**

### Code Quality Rules
- Keep code **modular**. One file = one clear responsibility.
- Use **clear, descriptive file and folder names.** No abbreviations that require decoding.
- Keep **UI components reusable**. Extract repeated patterns into shared components.
- Keep **mock data separate from UI code**. No hardcoded strings or arrays inside screen files.
- Prefer **simple, reliable prototype logic** over complex unfinished systems.
- Define **typed models** for all data structures in `src/models/`.
- **Agent logic stays in `src/agents/`.** Never embed business logic inside components or screens.

### Documentation Rules
- Add a brief comment block at the top of each agent file explaining its role.
- Document any function that performs non-obvious logic.
- Preserve all existing comments when editing files.

---

## 13. Suggested Folder Structure

```
CIRO/
├── AGENTS.md                    ← This file (project instructions)
├── README.md                    ← Public-facing project overview
├── package.json
├── app.json
│
└── src/
    ├── agents/                  ← One file per agent
    │   ├── signalAgent.js
    │   ├── fusionAgent.js
    │   ├── detectionAgent.js
    │   ├── severityAgent.js
    │   ├── resourceAgent.js
    │   ├── responsePlannerAgent.js
    │   ├── simulationAgent.js
    │   ├── verificationAgent.js
    │   └── logAgent.js
    │
    ├── components/              ← Reusable UI components
    │   ├── CrisisCard.jsx
    │   ├── SeverityBadge.jsx
    │   ├── AgentLogEntry.jsx
    │   ├── MetricDelta.jsx
    │   ├── ActionItem.jsx
    │   └── SignalChip.jsx
    │
    ├── screens/                 ← One file per screen
    │   ├── SplashScreen.jsx
    │   ├── LocationScreen.jsx
    │   ├── DashboardScreen.jsx
    │   ├── CrisisDetailScreen.jsx
    │   ├── ResponsePlanScreen.jsx
    │   ├── SimulationScreen.jsx
    │   ├── AgentLogsScreen.jsx
    │   ├── MapScreen.jsx
    │   ├── ReportsScreen.jsx
    │   ├── DemoScenariosScreen.jsx
    │   └── SettingsScreen.jsx
    │
    ├── data/                    ← All mock data files
    │   ├── mockSignals.js
    │   ├── mockCrises.js
    │   ├── mockResources.js
    │   ├── mockActionPlans.js
    │   ├── mockSimulations.js
    │   ├── mockAgentLogs.js
    │   └── mockDemoScenarios.js
    │
    ├── models/                  ← Typed data schema definitions
    │   ├── Signal.js
    │   ├── Crisis.js
    │   ├── Resource.js
    │   ├── ActionPlan.js
    │   ├── SimulationResult.js
    │   └── AgentLog.js
    │
    ├── services/                ← Orchestration and pipeline services
    │   ├── crisisPipeline.js    ← Runs the full agent pipeline
    │   └── locationService.js   ← Handles location permission + mock selection
    │
    ├── utils/                   ← Shared utility functions
    │   ├── formatters.js
    │   ├── severityUtils.js
    │   └── timeUtils.js
    │
    ├── theme/                   ← Design system tokens
    │   ├── colors.js
    │   ├── typography.js
    │   └── spacing.js
    │
    └── navigation/              ← App navigation configuration
        └── AppNavigator.jsx
```

---

## 14. Demo Scenario — Primary Walkthrough

The following scenario is the **primary demonstration flow** for CIRO. It must be fully functional as a one-tap preloaded demo.

### Input Signals

| Source       | Signal                                                                       |
|--------------|------------------------------------------------------------------------------|
| Social Post  | *"G-10 mein pani bhar gaya hai, gaariyan phans gayi hain"* (Urdu, citizen)  |
| Weather      | Heavy Rainfall Alert — Islamabad — Red Category — Issued 14:32 PKT          |
| Traffic      | G-10 Markaz: 85% congestion spike — Multiple routes blocked                 |

### Agent Pipeline Execution

| Step                | Output                                                                 |
|---------------------|------------------------------------------------------------------------|
| Signal Agent        | 3 signals collected, normalized to standard schema                     |
| Fusion Agent        | High overlap detected — corroborating event in G-10 sector             |
| Detection Agent     | **Urban Flooding** — Location: G-10, Islamabad — Onset: ~14:15 PKT    |
| Severity Agent      | Severity: **Critical** — Confidence: **91%** — Est. Affected: 3,200+  |
| Resource Agent      | 2 rescue boats, 1 pumping unit, 3 emergency vehicles prioritized       |
| Response Planner    | 5-action coordinated plan generated                                    |
| Simulation Agent    | All 5 actions simulated with outcome metrics                           |
| Verification Agent  | ✅ Confirmed Crisis — No conflicting signals                           |
| Log Agent           | Full decision trace recorded — 9 entries                               |

### Response Actions

1. Reroute traffic away from G-10 Markaz via I-8 alternate
2. Dispatch rescue team (2 boats + personnel) — ETA 8 minutes
3. Broadcast public alert to 4,800 registered residents
4. Create Emergency Ticket #CR-2024-0847 → NDMA + CDA Drainage
5. Notify Islamabad Capital Territory Disaster Management Authority

### Simulation Results (Before vs After)

| Metric              | Before   | After    | Change       |
|---------------------|----------|----------|--------------|
| Congestion %        | 88%      | 52%      | ▼ 36%        |
| Response Time       | 18 min   | 7 min    | ▼ 11 min     |
| Risk Level          | Critical | Moderate | ▼ Improving  |
| Affected People     | 3,200    | 850      | ▼ 2,350      |
| Resources Deployed  | 0        | 6 units  | ▲ 6          |
| Alerts Sent         | 0        | 4,800    | ▲ 4,800      |

---

## 15. Final Delivery Expectations

The completed CIRO prototype must clearly demonstrate all of the following to a non-technical audience in a live 5–10 minute demo:

| Capability                    | What the Demo Shows                                           |
|-------------------------------|---------------------------------------------------------------|
| **Multi-Source Input**        | Signals arriving from social, weather, and traffic sources    |
| **Crisis Detection**          | Correct identification of crisis type and affected location   |
| **Reasoning & Confidence**    | Agent-level decision summaries with confidence scores         |
| **Response Planning**         | Ordered, resource-assigned action plans                       |
| **Action Simulation**         | Visible execution of rerouting, dispatch, alerts, tickets     |
| **Outcome Visualization**     | Before/after metric panels with delta indicators              |
| **Agent Trace / Logs**        | Timestamped audit trail of every agent decision               |
| **Professional UI/UX**        | A design that looks like a real emergency operations product  |

The prototype must be **stable, impressive, and self-explanatory**. A non-technical evaluator should immediately understand what CIRO does and why it matters — without any verbal explanation.

---

*Last updated: 2026-05-17 | Version: 1.0.0 | Status: Active*
