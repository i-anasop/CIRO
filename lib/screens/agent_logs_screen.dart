// CIRO — Agent Logs / Trace Screen v6
// Exact pixel-perfect implementation of the provided UI design (Screen 4).
// 100% interactive and fully functional dynamic logs: tabbed view switching, stateful collapsible reasoning details, real-time matching with the active crisis scenario, and custom dashed tactical timeline.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/scenario_engine.dart';
import '../models/crisis.dart';

class AgentLogsScreen extends StatefulWidget {
  const AgentLogsScreen({super.key});

  @override
  State<AgentLogsScreen> createState() => _AgentLogsScreenState();
}

class _AgentLogsScreenState extends State<AgentLogsScreen> {
  String _activeTab = 'Agent Timeline'; // 'Agent Timeline' or 'Summary'
  int _expandedIndex = -1; // Collapsible drawer per agent card

  // Dynamic templates matching the selected crisis category type
  List<_AgentStep> _getStepsForCrisis(Crisis crisis) {
    final type = crisis.typeLabel.toLowerCase();
    
    if (type.contains('flood') || type.contains('water')) {
      return [
        _AgentStep(
          time: '10:32 AM',
          agent: 'Signal Agent',
          status: 'Completed',
          detail: 'Ingested 27 signals from weather, sensors, social media, and reports.',
          pill: '27 signals',
          pillColor: const Color(0xFF4F46E5),
          pillBg: const Color(0xFFEEF2FF),
          icon: Icons.radar_rounded,
          reasoning: '>>> SIGNAL INGESTION SYSTEM PIPELINE ACTIVE\n- Social Posts: Urdu token matching "pani bhar gaya" resolved to Flooding (Confidence: 89%)\n- Weather Station: Heavy Rainfall Alert (Red status, 50mm expected within 1 hour)\n- Traffic Grid: F-7/G-10 congestion spike detected (85% delay factor)',
        ),
        _AgentStep(
          time: '10:33 AM',
          agent: 'Detection Agent',
          status: 'Completed',
          detail: 'Anomaly detected in rainfall intensity and water level rise in F-7 Markaz.',
          pill: 'Anomaly Score: 0.86',
          pillColor: const Color(0xFF4F46E5),
          pillBg: const Color(0xFFEEF2FF),
          icon: Icons.search_rounded,
          reasoning: '>>> CRITICAL ANOMALY CLASSIFIED\n- Water sensors at F-7 Markaz underpass report water levels exceeded 2.4 meters (Warning threshold: 1.5m)\n- Anomaly Score: 0.86 indicating verified urban water logging event.',
        ),
        _AgentStep(
          time: '10:34 AM',
          agent: 'Severity Agent',
          status: 'Completed',
          detail: 'Assessed potential impact based on exposure, depth, and population.',
          pill: 'Severity: High',
          pillColor: Colors.orange,
          pillBg: const Color(0xFFFFF7ED),
          icon: Icons.warning_amber_rounded,
          reasoning: '>>> IMPACT RISK ESTIMATOR RUNNING\n- Expected water depth: 3.2 feet at critical bypass point\n- Affected citizens estimate: 3,200+ commuters in the block\n- Escalation risk: High due to continuous downpour',
        ),
        _AgentStep(
          time: '10:35 AM',
          agent: 'Response Planner Agent',
          status: 'Completed',
          detail: 'Recommended response actions and resource allocation.',
          pill: 'Plan Generated',
          pillColor: Colors.green,
          pillBg: const Color(0xFFF0FDF4),
          icon: Icons.assignment_turned_in_rounded,
          reasoning: '>>> ORCHESTRATED RESPONSE TASK LISTING\n- ACTION 1: Dispatch heavy drainage pump squad (ETA: 8 mins)\n- ACTION 2: Reroute Blue Line transit via alternative highway lanes\n- ACTION 3: Transmit emergency broadcast SMS to 4,800 local zone cellphones',
        ),
        _AgentStep(
          time: '10:36 AM',
          agent: 'Simulation Agent',
          status: 'In Progress',
          detail: 'Running flood spread simulation and impact estimation.',
          pill: 'ETA: 2 min',
          pillColor: const Color(0xFF8B5CF6),
          pillBg: const Color(0xFFF5F3FF),
          icon: Icons.play_circle_fill_rounded,
          isSimulation: true,
          reasoning: '>>> RUNNING DISPATCH OUTCOME SIMULATION\n- Model predicts water levels drop to safe levels in 45 minutes if pump is online by 10:45 AM\n- Rerouting lowers regional traffic congestion from 88% down to 52%',
        ),
      ];
    } else if (type.contains('accident') || type.contains('crash') || type.contains('collision')) {
      return [
        _AgentStep(
          time: '02:15 PM',
          agent: 'Signal Agent',
          status: 'Completed',
          detail: 'Ingested 14 signals from highway cameras, social media, and emergency desk.',
          pill: '14 signals',
          pillColor: const Color(0xFF4F46E5),
          pillBg: const Color(0xFFEEF2FF),
          icon: Icons.radar_rounded,
          reasoning: '>>> SIGNAL INGESTION SYSTEM PIPELINE ACTIVE\n- Camera feed G-9: Auto collision pattern match flagged\n- Twitter: Pakistani Urdu phrase "haadsa hua hai" detected near Srinagar Hwy\n- Emergency Desk: Multiple 1122 duplicate reports registered',
        ),
        _AgentStep(
          time: '02:16 PM',
          agent: 'Detection Agent',
          status: 'Completed',
          detail: 'Accident confirmed at Srinagar Highway. Multiple vehicle blockage.',
          pill: 'Anomaly Score: 0.94',
          pillColor: const Color(0xFF4F46E5),
          pillBg: const Color(0xFFEEF2FF),
          icon: Icons.search_rounded,
          reasoning: '>>> ACCIDENT IDENTIFICATION COMPLETED\n- Location classified: Srinagar Highway Main Transit Route\n- Blockage verified across 2 primary lanes',
        ),
        _AgentStep(
          time: '02:17 PM',
          agent: 'Severity Agent',
          status: 'Completed',
          detail: 'Assessed casualty risk, structural blockage, and detour potential.',
          pill: 'Severity: High',
          pillColor: Colors.orange,
          pillBg: const Color(0xFFFFF7ED),
          icon: Icons.warning_amber_rounded,
          reasoning: '>>> CASUALTY RISK FORECASTER\n- 2 drivers reported injured (Moderate severity classification)\n- Delay risk: Critical blockage on capital main freeway',
        ),
        _AgentStep(
          time: '02:18 PM',
          agent: 'Response Planner Agent',
          status: 'Completed',
          detail: 'Orchestrated dispatch parameters for rescue ambulances and traffic detours.',
          pill: 'Plan Generated',
          pillColor: Colors.green,
          pillBg: const Color(0xFFF0FDF4),
          icon: Icons.assignment_turned_in_rounded,
          reasoning: '>>> EMERGENCY RESOURCE LOGS\n- ACTION 1: Dispatch ambulance squad from Sector I-8 Base (ETA: 6 mins)\n- ACTION 2: Direct capital police transit cruiser to establish barricades',
        ),
        _AgentStep(
          time: '02:19 PM',
          agent: 'Simulation Agent',
          status: 'In Progress',
          detail: 'Simulating clearing time and traffic recovery curves.',
          pill: 'ETA: 4 min',
          pillColor: const Color(0xFF8B5CF6),
          pillBg: const Color(0xFFF5F3FF),
          icon: Icons.play_circle_fill_rounded,
          isSimulation: true,
          reasoning: '>>> CLEARANCE CURVE SIMULATION\n- Complete lane recovery estimate: 32 minutes\n- Detention risk: Reduced by 45% using arterial diversion strategy',
        ),
      ];
    } else {
      // General backup template for other types (outage, blockage, heatwave)
      return [
        _AgentStep(
          time: '04:02 PM',
          agent: 'Signal Agent',
          status: 'Completed',
          detail: 'Ingested signals and normalized local grid complaints.',
          pill: '12 signals',
          pillColor: const Color(0xFF4F46E5),
          pillBg: const Color(0xFFEEF2FF),
          icon: Icons.radar_rounded,
          reasoning: '>>> INCIDENT TELEMETRY CAPTURED\n- Utility grid alerts: 4 feeder stations reporting failure status\n- User complaints: 8 text signals verified in target block',
        ),
        _AgentStep(
          time: '04:03 PM',
          agent: 'Detection Agent',
          status: 'Completed',
          detail: 'System anomaly verified: Infrastructural outage.',
          pill: 'Anomaly Score: 0.78',
          pillColor: const Color(0xFF4F46E5),
          pillBg: const Color(0xFFEEF2FF),
          icon: Icons.search_rounded,
          reasoning: '>>> CRITICAL OUTAGE EVENT MATCHED\n- Core infrastructure failure diagnosed near grid residential perimeter.',
        ),
        _AgentStep(
          time: '04:04 PM',
          agent: 'Severity Agent',
          status: 'Completed',
          detail: 'Calculated blackout perimeter and secondary fire risks.',
          pill: 'Severity: Moderate',
          pillColor: Colors.orange,
          pillBg: const Color(0xFFFFF7ED),
          icon: Icons.warning_amber_rounded,
          reasoning: '>>> UTILITY SEVERITY ASSESSOR\n- Outage zone: 850 residential connections down\n- Secondary Risk: Low (Fire barriers checked)',
        ),
        _AgentStep(
          time: '04:05 PM',
          agent: 'Response Planner Agent',
          status: 'Completed',
          detail: 'Assigned grid engineer crew and backup power tickets.',
          pill: 'Plan Generated',
          pillColor: Colors.green,
          pillBg: const Color(0xFFF0FDF4),
          icon: Icons.assignment_turned_in_rounded,
          reasoning: '>>> DIRECTIVE PLAN CREATED\n- Crew ticket dispatched to engineering division\n- ETA to site: 14 mins',
        ),
        _AgentStep(
          time: '04:06 PM',
          agent: 'Simulation Agent',
          status: 'In Progress',
          detail: 'Simulating restoration ETA and grid load distribution.',
          pill: 'ETA: 1 min',
          pillColor: const Color(0xFF8B5CF6),
          pillBg: const Color(0xFFF5F3FF),
          icon: Icons.play_circle_fill_rounded,
          isSimulation: true,
          reasoning: '>>> POWER RESTORATION SIMULATOR\n- Estimated power return: 60 minutes after engineer arrives on-site.',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFFF8FAFC);
    final titleColor = const Color(0xFF0F172A);
    final subtitleColor = const Color(0xFF64748B);
    final activeTabColor = const Color(0xFF4F46E5);

    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        final engine = ScenarioEngine.instance;
        final crisis = engine.activeCrisis;
        final steps = _getStepsForCrisis(crisis);

        return Scaffold(
          backgroundColor: themeBg,
          appBar: AppBar(
            backgroundColor: themeBg,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: titleColor),
                  ),
                ),
              ),
            ),
            title: Column(
              children: [
                Text(
                  'Agent Trace',
                  style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Report ID: CR-${crisis.id.replaceAll("CR-", "")}',
                  style: TextStyle(color: subtitleColor, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune_rounded, size: 16, color: titleColor),
                      onPressed: () {
                        setState(() {
                          _expandedIndex = -1; // Reset drawers
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logs filter: High Severity Agent logs active.')),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Overall Assessment Card ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          crisis.typeLabel.toLowerCase().contains('flood')
                              ? Icons.waves_rounded
                              : (crisis.typeLabel.toLowerCase().contains('accident')
                                  ? Icons.car_crash_rounded
                                  : Icons.warning_amber_rounded),
                          color: activeTabColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Assessment',
                              style: TextStyle(color: subtitleColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${crisis.typeLabel} • Confidence: ${crisis.confidencePercent}%',
                              style: TextStyle(color: titleColor, fontSize: 13.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                        ),
                        child: Text(
                          crisis.severityLabel.toUpperCase(),
                          style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tab Bar Toggle ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'Agent Timeline'),
                        child: Column(
                          children: [
                            Text(
                              'Agent Timeline',
                              style: TextStyle(
                                color: _activeTab == 'Agent Timeline' ? titleColor : subtitleColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: _activeTab == 'Agent Timeline' ? activeTabColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'Summary'),
                        child: Column(
                          children: [
                            Text(
                              'Summary',
                              style: TextStyle(
                                color: _activeTab == 'Summary' ? titleColor : subtitleColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: _activeTab == 'Summary' ? activeTabColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Dynamic Body Render ─────────────────────────────────────────
              Expanded(
                child: _activeTab == 'Agent Timeline'
                    ? _buildTimelineList(steps)
                    : _buildSummaryTab(crisis),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 1: Timeline List with custom dashed line structure ──────────────────
  Widget _buildTimelineList(List<_AgentStep> steps) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: steps.length + 1, // Last index is the footer safety shield
      itemBuilder: (context, index) {
        if (index == steps.length) {
          // Bottom Shield Banner
          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.green, size: 16),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'All critical agents active and operating normally.',
                      style: TextStyle(color: Color(0xFF166534), fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final step = steps[index];
        final isExpanded = _expandedIndex == index;
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timestamp column
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      step.time,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              // Tactical Dashed Line column
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: step.pillColor, width: 2),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: CustomPaint(
                          size: const Size(1, double.infinity),
                          painter: _DashedLinePainter(color: const Color(0xFFCBD5E1)),
                        ),
                      ),
                  ],
                ),
              ),

              // Expandable Card details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isExpanded ? step.pillColor : const Color(0xFFE2E8F0),
                        width: isExpanded ? 1.4 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row details
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? -1 : index;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: step.pillBg, shape: BoxShape.circle),
                                    child: Icon(step.icon, color: step.pillColor, size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    step.agent,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: step.isSimulation ? const Color(0xFFFFF7ED) : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      step.status,
                                      style: TextStyle(
                                        color: step.isSimulation ? Colors.orange : Colors.green,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (step.isSimulation)
                                      const SizedBox(
                                        width: 8, height: 8,
                                        child: CircularProgressIndicator(
                                          color: Colors.orange,
                                          strokeWidth: 1.5,
                                        ),
                                      )
                                    else
                                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Detail summary row
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? -1 : index;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  step.detail,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.chevron_right_rounded,
                                color: const Color(0xFF64748B),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bottom label row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: step.pillBg, borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                step.pill,
                                style: TextStyle(color: step.pillColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (step.isSimulation)
                              const SizedBox(
                                width: 12, height: 12,
                                child: CircularProgressIndicator(color: Color(0xFF8B5CF6), strokeWidth: 1.5),
                              ),
                          ],
                        ),

                        // Stateful expandable reasoning trace overlay
                        if (isExpanded) ...[
                          const SizedBox(height: 14),
                          const Divider(color: Color(0xFFE2E8F0), height: 1),
                          const SizedBox(height: 10),
                          const Text(
                            'AI AGENT DECISION TRACE & REASONING AUDIT:',
                            style: TextStyle(
                              color: Color(0xFF4F46E5),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: SelectableText(
                              step.reasoning,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontFamily: 'monospace',
                                fontSize: 9.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 2: Executive Summary Tab ───────────────────────────────────────────
  Widget _buildSummaryTab(Crisis crisis) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crisis Operations Summary',
            style: TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comprehensive diagnostic summary automatically synthesized by CIRO Multi-Agent pipeline orchestration.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Core status grid
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Active Agents',
                  '9 / 9',
                  'All engines online',
                  Icons.smart_toy_outlined,
                  const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildSummaryCard(
                  'Verification',
                  'Confirmed',
                  'High confidence',
                  Icons.gpp_good_outlined,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Comprehensive summary statement text container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description_outlined, color: Color(0xFF4F46E5), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Executive Action Statement',
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'The CIRO system ingested multiple overlapping signals regarding "${crisis.typeLabel}" at "${crisis.location}". Signal corroboration across official weather warnings and traffic delay spikes yielded an Overall Assessment rating of ${crisis.severityLabel.toUpperCase()} (Confidence: ${crisis.confidencePercent}%).\n\nEmergency dispatch units have been alerted and alternate routing calculations are underway. Live telemetry remains operational.',
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a clean tactical dashed timeline path on left
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double maxH = size.height;
    double startY = 0;
    double dashLength = 4;
    double spaceLength = 3;

    while (startY < maxH) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashLength), paint);
      startY += dashLength + spaceLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Model class to hold timeline agent steps cleanly in memory
class _AgentStep {
  final String time;
  final String agent;
  final String status;
  final String detail;
  final String pill;
  final Color pillColor;
  final Color pillBg;
  final IconData icon;
  final bool isSimulation;
  final String reasoning;

  _AgentStep({
    required this.time,
    required this.agent,
    required this.status,
    required this.detail,
    required this.pill,
    required this.pillColor,
    required this.pillBg,
    required this.icon,
    this.isSimulation = false,
    required this.reasoning,
  });
}
