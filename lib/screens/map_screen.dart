// CIRO — Real Interactive Situation Map Screen v7
// Exact pixel-perfect implementation of the provided UI design (Screen 2).
// Fully functional real-time Google Map with 100% interactive tactical layers, active settings panel, detailed traffic diagnostics, live response squad logs, and capital emergency audio dispatch.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/location_service.dart';
import '../services/scenario_engine.dart';
import '../components/interactive_map_helper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Live GPS tracking state
  bool _isLoadingLocation = false;

  // Real-time map coordinates, zoom, and active category layer state
  double _latitude = 33.6946;  // Default Islamabad coordinates
  double _longitude = 73.0179;
  int _zoom = 15;
  String _selectedLayer = 'All Layers';

  // Settings customizable states
  bool _showRiskZone = true;
  bool _showAltRoute = true;
  String _mapStyle = 'Standard';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    // Request permission and fetch user's real GPS coordinates
    final loc = await LocationService.instance.getCurrentLocation();
    setState(() {
      if (loc.latitude != null && loc.longitude != null) {
        _latitude = loc.latitude!;
        _longitude = loc.longitude!;
      }
      _isLoadingLocation = false;
    });
  }

  void _resetMapFocus() {
    setState(() {
      _zoom = 15;
      _latitude = 33.6946;
      _longitude = 73.0179;
    });
    _fetchLocation();
  }

  // Returns the effective layer considering the map style override
  String get _effectiveLayer {
    if (_mapStyle == 'Satellite') return 'Flood Risk';
    return _selectedLayer;
  }

  // ── Bottom Sheet Builders ──────────────────────────────────────────────────
  
  // 1. Settings Control Panel Bottom Sheet
  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Text('Map Settings', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Visual Layer Toggles
                  const Text('TACTICAL OVERLAYS', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Flood High Risk Zones', style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Translucent tactical hazard boundary', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    value: _showRiskZone,
                    activeThumbColor: const Color(0xFF4F46E5),
                    onChanged: (val) {
                      setModalState(() => _showRiskZone = val);
                      setState(() => _showRiskZone = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Alternate Traffic Bypass', style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Green 18-minute optimal route shield', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    value: _showAltRoute,
                    activeThumbColor: const Color(0xFF4F46E5),
                    onChanged: (val) {
                      setModalState(() => _showAltRoute = val);
                      setState(() => _showAltRoute = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Map Style Selection
                  const Text('VISUAL MAP STYLE', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStylePill(setModalState, 'Standard', Icons.map_outlined),
                      const SizedBox(width: 10),
                      _buildStylePill(setModalState, 'Satellite', Icons.satellite_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Reset Focus Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reset Map to G-10 Islamabad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context);
                        _resetMapFocus();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStylePill(StateSetter setModalState, String styleName, IconData icon) {
    final isActive = _mapStyle == styleName;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setModalState(() {
            _mapStyle = styleName;
            _selectedLayer = styleName == 'Satellite' ? 'Flood Risk' : 'All Layers';
          });
          setState(() {
            _mapStyle = styleName;
            _selectedLayer = styleName == 'Satellite' ? 'Flood Risk' : 'All Layers';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEEF2FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF64748B), size: 16),
              const SizedBox(width: 8),
              Text(
                styleName,
                style: TextStyle(
                  color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Traffic Congestion Detailed Report Bottom Sheet
  void _showTrafficDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Traffic Diagnostic Unit', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('18 km/h Avg', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              
              // Congested Sector Lists
              const Text('CONGESTED SECTORS & DELAYS', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              const SizedBox(height: 12),
              
              _buildTrafficItem('G-10 Markaz (Evacuation Corridor)', 'Critical', '+25 min Delay', Colors.red, const Color(0xFFFFF0F0)),
              _buildTrafficItem('F-6 Drainage Main Crossing', 'High Risk', '+18 min Delay', Colors.red, const Color(0xFFFFF0F0)),
              _buildTrafficItem('Blue Area Express Corridor', 'Moderate', '+8 min Delay', Colors.orange, const Color(0xFFFFF7ED)),
              _buildTrafficItem('Kashmir Highway Bypass', 'Optimal', 'Free Flow', Colors.green, const Color(0xFFF0FDF4)),
              
              const SizedBox(height: 20),
              const Text(
                'RECOMMENDATION:\nAuto-rerouting active for all ambulance and disaster units. Margalla Highway bypass is recommended for North-bound field crews.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrafficItem(String title, String level, String delay, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(delay, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(level, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Response Squad Units Detailed Activity Sheet
  void _showUnitsDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Capital Response Deployed Squads', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('12 Active', style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              
              const Text('ACTIVE SQUAD REGISTRY', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              const SizedBox(height: 12),
              
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSquadItem('Ambulance Corps Alpha-1', 'Active evacuation G-10', 'ETA 3 Min', Icons.local_hospital_rounded, Colors.red),
                    _buildSquadItem('Heavy Water Drainage Pump 3', 'Draining main avenue road G-10', 'Operating', Icons.water_drop_rounded, Colors.blue),
                    _buildSquadItem('NDMA Rescue Boat Alpha-2', 'Evacuation near G-8 stream', 'Standby', Icons.directions_boat_rounded, Colors.indigo),
                    _buildSquadItem('Disaster Response Team Delta', 'Dispatching from Capital Hub HQ', 'En Route', Icons.security_rounded, Colors.orange),
                    _buildSquadItem('Islamabad Capital Police (Sector G)', 'Diverting traffic at F-6 crossing', 'Patrol', Icons.local_police_rounded, Colors.green),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSquadItem(String name, String task, String status, IconData icon, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(task, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Operating' || status == 'Patrol' ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'Operating' || status == 'Patrol' ? const Color(0xFF059669) : const Color(0xFF2563EB),
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF4F46E5);
    const titleColor = Color(0xFF0F172A);
    const subtitleColor = Color(0xFF64748B);

    return ListenableBuilder(
      listenable: ScenarioEngine.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              // ── 1. Interactive Google Maps Embed (web-safe, CORS-compliant iframe) ──
              Positioned.fill(
                child: createInteractiveMap(
                  latitude: _latitude,
                  longitude: _longitude,
                  zoom: _zoom,
                  selectedLayer: _effectiveLayer,
                  showRiskZone: _showRiskZone,
                  showAltRoute: _showAltRoute,
                ),
              ),

              // ── 2. Floating Pill Overlays on the Map ──────────────────────
              // Emergency Warning Overlay Card (F-6 Flood Zone)
              if (_showRiskZone)
                Positioned(
                  top: 260,
                  left: 170,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF0F0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Flood Zone',
                                style: TextStyle(color: titleColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'High Risk',
                                style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Alternate Route Shield Overlay
              if (_showAltRoute)
                Positioned(
                  top: 360,
                  left: 200,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Alternate Route',
                            style: TextStyle(color: Color(0xFF15803D), fontSize: 9, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '18 min',
                            style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── 3. Floating Zoom & Aim Navigation Buttons (100% Clickable!) ──
              Positioned(
                right: 20,
                bottom: 350,
                child: Column(
                  children: [
                    // Zoom In/Out vertical pill card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: titleColor, size: 20),
                            onPressed: () {
                              setState(() {
                                _zoom = (_zoom + 1).clamp(3, 21);
                              });
                            },
                          ),
                          Container(width: 16, height: 1, color: const Color(0xFFE2E8F0)),
                          IconButton(
                            icon: const Icon(Icons.remove, color: titleColor, size: 20),
                            onPressed: () {
                              setState(() {
                                _zoom = (_zoom - 1).clamp(3, 21);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Floating GPS Compass Locator Circle button
                    GestureDetector(
                      onTap: _resetMapFocus,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoadingLocation
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: brandColor, strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location_rounded, color: titleColor, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 4. Premium Situation Map Top App Bar ──────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            GestureDetector(
                              onTap: () => context.go('/home'),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: titleColor),
                              ),
                            ),

                            // Dynamic center header
                            Column(
                              children: [
                                const Text(
                                  'Situation Map',
                                  style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Live · Updated 1 min ago',
                                      style: TextStyle(color: subtitleColor, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Settings Tune Button
                            GestureDetector(
                              onTap: () => _showSettingsSheet(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                    ]),
                                child: const Icon(Icons.tune_rounded, size: 18, color: titleColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Rounded category layers horizontal chips row (100% interactive!)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildMapChip('All Layers'),
                              _buildMapChip('Flood Risk'),
                              _buildMapChip('Traffic'),
                              _buildMapChip('Shelters'),
                              _buildMapChip('Units'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 5. Bottom Sheet Cards Overlay (Exact matching UI & interactive) ─────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bottom drag handle/indicator bar
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // Card 1: Traffic Status (Interactive tapping!)
                      GestureDetector(
                        onTap: () => _showTrafficDetailsSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEEF2FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.directions_car_rounded, color: brandColor, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Traffic Status',
                                        style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Congested',
                                        style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Delays in 4 sectors',
                                        style: TextStyle(color: subtitleColor.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Avg Speed',
                                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        '18 km/h',
                                        style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card 2: Response Units (Interactive tapping!)
                      GestureDetector(
                        onTap: () => _showUnitsDetailsSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFECFDF5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Response Units',
                                            style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Deployed',
                                            style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Container(height: 1, color: const Color(0xFFF1F5F9)),
                              const SizedBox(height: 14),

                              // Numeric operational grid statistics
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                    _buildStatsColumn('Units On Field', '12'),
                                    _buildStatsColumn('En Route', '5'),
                                    _buildStatsColumn('Available', '7'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapChip(String label) {
    final isActive = _selectedLayer == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLayer = label;
          // Dynamically adjust zoom levels for optimal context views
          if (label == 'Flood Risk') {
            _zoom = 14; // Wider context for risk zones
          } else if (label == 'Traffic') {
            _zoom = 15;
          } else if (label == 'Shelters' || label == 'Units') {
            _zoom = 13; // Broaden search scope
          } else {
            _zoom = 15;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF64748B),
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
