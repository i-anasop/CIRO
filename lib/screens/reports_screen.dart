import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/location_service.dart';
import '../services/scenario_engine.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _brand = Color(0xFF5A5CE5);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);

  final TextEditingController _postController = TextEditingController();
  final List<_FeedItem> _feed = _seedFeed();
  String _selectedType = 'Flood';
  bool _photoAttached = false;
  bool _locationAttached = false;
  bool _analyzing = false;
  String _locationLabel = 'G-10, Islamabad';
  double _lat = 33.6946;
  double _lng = 73.0179;

  final Map<String, _CrisisTemplate> _templates = {
    'Flood': const _CrisisTemplate(
      title: 'Urban Flooding',
      prompt:
          'Water is rising near G-10 Markaz. Service road traffic is slowing and residents need drainage support.',
      location: 'G-10 Markaz',
      lat: 33.6946,
      lng: 73.0179,
      color: Color(0xFF2563EB),
      icon: Icons.water_drop_rounded,
    ),
    'Accident': const _CrisisTemplate(
      title: 'Road Accident',
      prompt:
          'Multiple vehicles are blocking a lane. Traffic needs diversion and emergency support.',
      location: 'Srinagar Highway',
      lat: 33.6840,
      lng: 73.0450,
      color: Color(0xFFF97316),
      icon: Icons.car_crash_rounded,
    ),
    'Power': const _CrisisTemplate(
      title: 'Power Outage',
      prompt:
          'Street lights and homes are without power. Utility repair support may be needed.',
      location: 'G-10/2',
      lat: 33.6970,
      lng: 73.0150,
      color: Color(0xFFF59E0B),
      icon: Icons.power_off_rounded,
    ),
    'Heat': const _CrisisTemplate(
      title: 'Heat Stress',
      prompt:
          'Outdoor workers and elderly residents need cooling support and water access.',
      location: 'F-10',
      lat: 33.6992,
      lng: 73.0096,
      color: Color(0xFF14B8A6),
      icon: Icons.thermostat_rounded,
    ),
  };

  @override
  void initState() {
    super.initState();
    _postController.text = _templates[_selectedType]!.prompt;
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _attachLocation() async {
    final loc = await LocationService.instance.getCurrentLocation();
    setState(() {
      _locationAttached = true;
      if (loc.latitude != null && loc.longitude != null) {
        _lat = loc.latitude!;
        _lng = loc.longitude!;
        _locationLabel =
            'My location (${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)})';
      } else {
        final template = _templates[_selectedType]!;
        _lat = template.lat;
        _lng = template.lng;
        _locationLabel = '${template.location} fallback';
      }
    });
  }

  Future<void> _postReport() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() => _analyzing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final template = _templates[_selectedType]!;
    final item = _FeedItem(
      author: 'You',
      handle: '@local_reporter',
      time: 'now',
      title: template.title,
      body: text,
      location: _locationAttached ? _locationLabel : template.location,
      tag: 'New',
      icon: template.icon,
      color: template.color,
      likes: 0,
      comments: 0,
      shares: 0,
    );

    ScenarioEngine.instance.overrideLocation(
      item.location,
      lat: _locationAttached ? _lat : template.lat,
      lng: _locationAttached ? _lng : template.lng,
    );

    setState(() {
      _feed.insert(0, item);
      _analyzing = false;
      _photoAttached = false;
      _locationAttached = false;
      _locationLabel = 'G-10, Islamabad';
      _postController.text = template.prompt;
    });
  }

  void _selectType(String type) {
    final template = _templates[type]!;
    setState(() {
      _selectedType = type;
      _postController.text = template.prompt;
      _lat = template.lat;
      _lng = template.lng;
      _locationLabel = template.location;
      _locationAttached = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
          children: [
            Row(
              children: [
                _IconCircle(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.go('/home'),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crisis Feed',
                        style: TextStyle(
                          color: _text,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Local alerts, reports, and response updates',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _IconCircle(
                  icon: Icons.map_rounded,
                  onTap: () => context.go('/map'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ComposerCard(
              controller: _postController,
              selectedType: _selectedType,
              templates: _templates,
              photoAttached: _photoAttached,
              locationAttached: _locationAttached,
              locationLabel: _locationLabel,
              analyzing: _analyzing,
              onTypeSelected: _selectType,
              onPhoto: () => setState(() => _photoAttached = !_photoAttached),
              onLocation: _attachLocation,
              onPost: _postReport,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Latest nearby reports',
                    style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _SmallChip(
                  icon: Icons.verified_rounded,
                  label: '${_feed.length} active',
                  color: _brand,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._feed.map((item) => _SocialPostCard(item: item)),
          ],
        ),
      ),
    );
  }
}

class _ComposerCard extends StatelessWidget {
  final TextEditingController controller;
  final String selectedType;
  final Map<String, _CrisisTemplate> templates;
  final bool photoAttached;
  final bool locationAttached;
  final String locationLabel;
  final bool analyzing;
  final ValueChanged<String> onTypeSelected;
  final VoidCallback onPhoto;
  final VoidCallback onLocation;
  final VoidCallback onPost;

  const _ComposerCard({
    required this.controller,
    required this.selectedType,
    required this.templates,
    required this.photoAttached,
    required this.locationAttached,
    required this.locationLabel,
    required this.analyzing,
    required this.onTypeSelected,
    required this.onPhoto,
    required this.onLocation,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 19,
                backgroundColor: Color(0xFF5A5CE5),
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: 3,
                  minLines: 2,
                  style: const TextStyle(
                    color: _ReportsScreenState._text,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What is happening near you?',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: _ReportsScreenState._border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: _ReportsScreenState._border,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: templates.entries.map((entry) {
                final selected = selectedType == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onTypeSelected(entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? entry.value.color.withValues(alpha: 0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? entry.value.color
                              : _ReportsScreenState._border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            entry.value.icon,
                            size: 15,
                            color: selected
                                ? entry.value.color
                                : _ReportsScreenState._muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: selected
                                  ? entry.value.color
                                  : _ReportsScreenState._text,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ComposerTool(
                icon: Icons.image_outlined,
                label: photoAttached ? 'Photo added' : 'Photo',
                active: photoAttached,
                onTap: onPhoto,
              ),
              const SizedBox(width: 8),
              _ComposerTool(
                icon: Icons.location_on_outlined,
                label: locationAttached ? 'Location added' : 'Location',
                active: locationAttached,
                onTap: onLocation,
              ),
              const Spacer(),
              Material(
                color: _ReportsScreenState._brand,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: analyzing ? null : onPost,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: analyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (locationAttached) ...[
            const SizedBox(height: 10),
            _SmallChip(
              icon: Icons.my_location_rounded,
              label: locationLabel,
              color: _ReportsScreenState._brand,
            ),
          ],
        ],
      ),
    );
  }
}

class _SocialPostCard extends StatefulWidget {
  final _FeedItem item;
  const _SocialPostCard({required this.item});

  @override
  State<_SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<_SocialPostCard> {
  late int _likes = widget.item.likes;
  late int _comments = widget.item.comments;
  late int _shares = widget.item.shares;
  bool _liked = false;
  final List<String> _localComments = [];

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _box(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: item.color.withValues(alpha: 0.12),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ReportsScreenState._text,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified_rounded,
                          color: item.color,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.handle} · ${item.time}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _SmallChip(icon: item.icon, label: item.tag, color: item.color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              color: _ReportsScreenState._text,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.body,
            style: const TextStyle(
              color: _ReportsScreenState._muted,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 132,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: item.color.withValues(alpha: 0.14)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  top: 18,
                  child: Icon(
                    item.icon,
                    color: item.color.withValues(alpha: 0.35),
                    size: 48,
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: _SmallChip(
                    icon: Icons.location_on_rounded,
                    label: item.location,
                    color: item.color,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Row(
                    children: [
                      _SmallChip(
                        icon: Icons.sensors_rounded,
                        label: 'Signal matched',
                        color: item.color,
                      ),
                      const SizedBox(width: 8),
                      _SmallChip(
                        icon: Icons.shield_rounded,
                        label: 'CIRO review',
                        color: _ReportsScreenState._brand,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PostAction(
                icon: _liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '$_likes',
                active: _liked,
                color: const Color(0xFFEF4444),
                onTap: () {
                  setState(() {
                    _liked = !_liked;
                    _likes += _liked ? 1 : -1;
                  });
                },
              ),
              const SizedBox(width: 10),
              _PostAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: '$_comments',
                color: _ReportsScreenState._brand,
                onTap: _openComments,
              ),
              const SizedBox(width: 10),
              _PostAction(
                icon: Icons.repeat_rounded,
                label: '$_shares',
                color: const Color(0xFF10B981),
                onTap: () => setState(() => _shares++),
              ),
              const Spacer(),
              const _FeedMetric(icon: Icons.visibility_outlined, label: '1.8k'),
            ],
          ),
        ],
      ),
    );
  }

  void _openComments() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                14,
                18,
                18 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _ReportsScreenState._border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Comments',
                    style: TextStyle(
                      color: _ReportsScreenState._text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CommentRow(
                    name: 'CIRO verifier',
                    text:
                        'Report is being checked against other local signals.',
                    color: widget.item.color,
                  ),
                  _CommentRow(
                    name: 'Nearby resident',
                    text:
                        'This matches what we are seeing from the service road.',
                    color: widget.item.color,
                  ),
                  ..._localComments.map(
                    (text) => _CommentRow(
                      name: 'You',
                      text: text,
                      color: _ReportsScreenState._brand,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Add a helpful update',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: _ReportsScreenState._border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: _ReportsScreenState._border,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: _ReportsScreenState._brand,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;
                            setState(() {
                              _localComments.add(text);
                              _comments++;
                            });
                            setSheet(() {});
                            controller.clear();
                          },
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ComposerTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ComposerTool({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? _ReportsScreenState._brand.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? _ReportsScreenState._brand
                : _ReportsScreenState._border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: active
                  ? _ReportsScreenState._brand
                  : _ReportsScreenState._muted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? _ReportsScreenState._brand
                    : _ReportsScreenState._text,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _PostAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = active ? color : _ReportsScreenState._muted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.10)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.20)
                : _ReportsScreenState._border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: display),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: display,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SmallChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeedMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CommentRow extends StatelessWidget {
  final String name;
  final String text;
  final Color color;

  const _CommentRow({
    required this.name,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _ReportsScreenState._border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.person_rounded, size: 15, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _ReportsScreenState._text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: _ReportsScreenState._muted,
                    fontSize: 11.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: _ReportsScreenState._text, size: 20),
        ),
      ),
    );
  }
}

BoxDecoration _box(double radius) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: _ReportsScreenState._border),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.025),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ],
);

class _CrisisTemplate {
  final String title;
  final String prompt;
  final String location;
  final double lat;
  final double lng;
  final Color color;
  final IconData icon;

  const _CrisisTemplate({
    required this.title,
    required this.prompt,
    required this.location,
    required this.lat,
    required this.lng,
    required this.color,
    required this.icon,
  });
}

class _FeedItem {
  final String author;
  final String handle;
  final String time;
  final String title;
  final String body;
  final String location;
  final String tag;
  final IconData icon;
  final Color color;
  final int likes;
  final int comments;
  final int shares;

  const _FeedItem({
    required this.author,
    required this.handle,
    required this.time,
    required this.title,
    required this.body,
    required this.location,
    required this.tag,
    required this.icon,
    required this.color,
    required this.likes,
    required this.comments,
    required this.shares,
  });
}

List<_FeedItem> _seedFeed() => const [
  _FeedItem(
    author: 'Ayesha Khan',
    handle: '@g10_resident',
    time: '4m',
    title: 'Water rising near G-10 Markaz',
    body:
        'Rainwater is collecting near the market edge. Smaller cars are slowing down and shop entrances are getting wet.',
    location: 'G-10 Markaz',
    tag: 'Verified',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF2563EB),
    likes: 42,
    comments: 8,
    shares: 12,
  ),
  _FeedItem(
    author: 'Traffic Warden Unit',
    handle: '@ict_traffic',
    time: '8m',
    title: 'Slow traffic on service road',
    body:
        'Three nearby road segments are moving below normal speed. Drivers should avoid the service road beside G-10/2.',
    location: 'Service Road West',
    tag: 'Traffic',
    icon: Icons.traffic_rounded,
    color: Color(0xFFF97316),
    likes: 31,
    comments: 6,
    shares: 18,
  ),
  _FeedItem(
    author: 'Relief Desk',
    handle: '@ciro_relief',
    time: '12m',
    title: 'Shelter intake ready',
    body:
        'G-10 Community Center can receive families if water enters homes. Basic meals and first aid are available.',
    location: 'G-10 Community Center',
    tag: 'Ready',
    icon: Icons.home_work_rounded,
    color: Color(0xFF10B981),
    likes: 28,
    comments: 4,
    shares: 9,
  ),
  _FeedItem(
    author: 'PIMS Emergency Desk',
    handle: '@pims_intake',
    time: '15m',
    title: 'Triage capacity checked',
    body:
        'Emergency wing is ready for minor injuries and exposure cases from nearby flooded lanes.',
    location: 'PIMS',
    tag: 'Hospital',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFF0EA5E9),
    likes: 24,
    comments: 5,
    shares: 7,
  ),
  _FeedItem(
    author: 'Field Team 3',
    handle: '@field_ops',
    time: '18m',
    title: 'Drainage crew requested',
    body:
        'Standing water reported near the market edge. Utility team asked to inspect a possible drain blockage.',
    location: 'G-10/2',
    tag: 'Action',
    icon: Icons.construction_rounded,
    color: Color(0xFF8B5CF6),
    likes: 19,
    comments: 3,
    shares: 6,
  ),
];
