import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_mode_service.dart';
import '../services/location_service.dart';
import '../services/post_database_service.dart';
import '../services/scenario_engine.dart';
import '../services/user_profile_service.dart';
import '../theme/colors.dart';
import '../utils/image_picker_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _postController = TextEditingController();
  List<_FeedPost> _posts = const [];

  static const int _postLimit = 280;
  String _selectedType = 'Flood';
  String _selectedFilter = 'Nearby';
  String? _attachedImageData;
  bool _locationAttached = false;
  bool _posting = false;
  String _locationLabel = AppModeService.instance.isDemoMode
      ? 'G-10 Markaz'
      : ScenarioEngine.instance.activeCrisis.location;
  double _lat = 33.6946;
  double _lng = 73.0179;

  final Map<String, _CrisisTemplate> _templates = {
    'Flood': const _CrisisTemplate(
      title: 'Urban flooding',
      prompt:
          'Water is rising near G-10 Markaz. Traffic is slowing and drainage support is needed.',
      location: 'G-10 Markaz',
      lat: 33.6946,
      lng: 73.0179,
      color: Color(0xFF2563EB),
      icon: Icons.water_drop_rounded,
    ),
    'Accident': const _CrisisTemplate(
      title: 'Road accident',
      prompt:
          'A lane is blocked after a collision. Please avoid the area and keep space for responders.',
      location: 'Srinagar Highway',
      lat: 33.6840,
      lng: 73.0450,
      color: Color(0xFFF97316),
      icon: Icons.car_crash_rounded,
    ),
    'Power': const _CrisisTemplate(
      title: 'Power outage',
      prompt:
          'Street lights and homes are without power. Utility verification may be needed.',
      location: 'G-10/2',
      lat: 33.6970,
      lng: 73.0150,
      color: Color(0xFFF59E0B),
      icon: Icons.power_off_rounded,
    ),
    'Heat': const _CrisisTemplate(
      title: 'Heat stress',
      prompt:
          'Outdoor workers and elderly residents need water access and cooling support.',
      location: 'F-10',
      lat: 33.6992,
      lng: 73.0096,
      color: Color(0xFF14B8A6),
      icon: Icons.thermostat_rounded,
    ),
  };

  IconData _iconFromName(String name) {
    switch (name) {
      case 'water_drop': return Icons.water_drop_rounded;
      case 'car_crash': return Icons.car_crash_rounded;
      case 'power_off': return Icons.power_off_rounded;
      case 'thermostat': return Icons.thermostat_rounded;
      default: return Icons.warning_rounded;
    }
  }

  String _nameFromIcon(IconData icon) {
    if (icon == Icons.water_drop_rounded) return 'water_drop';
    if (icon == Icons.car_crash_rounded) return 'car_crash';
    if (icon == Icons.power_off_rounded) return 'power_off';
    if (icon == Icons.thermostat_rounded) return 'thermostat';
    return 'warning';
  }

  Color _colorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', ''), radix: 16));
    } catch (_) {
      return CiroColors.brand;
    }
  }

  String _hexFromColor(Color color) {
    return '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  @override
  void initState() {
    super.initState();
    _postController.text = _templates[_selectedType]!.prompt;
    _posts = List<_FeedPost>.of(_seedPosts());
    _loadPersistedPosts();
  }

  Future<void> _loadPersistedPosts() async {
    final list = await PostDatabaseService.instance.loadPosts();
    if (list.isEmpty) return;

    final List<_FeedPost> persistedItems = [];
    for (final map in list) {
      final author = map['author'] ?? 'Anonymous';
      final avatarColor = map['avatarIndex'] != null
          ? UserProfileService.avatarColors[(map['avatarIndex'] as int).clamp(0, UserProfileService.avatarColors.length - 1)]
          : null;
      final avatarIcon = map['avatarIndex'] != null
          ? UserProfileService.avatarIcons[(map['avatarIndex'] as int).clamp(0, UserProfileService.avatarIcons.length - 1)]
          : null;
      persistedItems.add(
        _FeedPost(
          id: map['timestamp']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
          author: author,
          handle: map['handle'] ?? '@local_reporter',
          avatarText: author.isNotEmpty ? author[0].toUpperCase() : 'A',
          avatarColor: avatarColor,
          avatarIcon: avatarIcon,
          avatarImageData: map['customAvatarUrl'],
          time: 'now',
          title: map['title'] ?? '',
          body: map['body'] ?? '',
          location: map['location'] ?? '',
          tag: map['tag'] ?? 'New',
          icon: _iconFromName(map['iconName'] ?? ''),
          color: _colorFromHex(map['colorHex'] ?? ''),
          imageTone: _colorFromHex(map['colorHex'] ?? ''),
          likes: map['likes'] ?? 0,
          views: 1,
          comments: const [],
          isOfficial: false,
        ),
      );
    }

    setState(() {
      _posts.insertAll(0, persistedItems);
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _attachLocation() async {
    final loc = await LocationService.instance.getCurrentLocation();
    final template = _templates[_selectedType]!;
    setState(() {
      _locationAttached = true;
      if (loc.latitude != null && loc.longitude != null) {
        _lat = loc.latitude!;
        _lng = loc.longitude!;
        _locationLabel =
            'Current location ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}';
      } else {
        _lat = template.lat;
        _lng = template.lng;
        _locationLabel = '${template.location} fallback';
      }
    });
  }

  Future<void> _pickPhoto() async {
    final imageData = await pickImageBytes();
    if (!mounted || imageData == null) return;
    setState(() => _attachedImageData = imageData);
  }

  Future<void> _publishPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty || _posting) return;

    setState(() => _posting = true);
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    final profile = UserProfileService.instance;
    final template = _templates[_selectedType]!;
    final authorName = profile.name.trim().isEmpty
        ? 'You'
        : profile.name.trim();
    final handle = profile.role.trim().isEmpty
        ? '@local_reporter'
        : '@${profile.role.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+$'), '')}';
    final post = _FeedPost(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: authorName,
      handle: handle == '@' ? '@local_reporter' : handle,
      avatarText: authorName.characters.first.toUpperCase(),
      avatarImageData: profile.customAvatarUrl,
      avatarColor:
          UserProfileService.avatarColors[profile.avatarIndex.clamp(
            0,
            UserProfileService.avatarColors.length - 1,
          )],
      avatarIcon:
          UserProfileService.avatarIcons[profile.avatarIndex.clamp(
            0,
            UserProfileService.avatarIcons.length - 1,
          )],
      time: 'now',
      title: template.title,
      body: text,
      location: _locationAttached ? _locationLabel : template.location,
      tag: 'New report',
      icon: template.icon,
      color: template.color,
      imageTone: template.color,
      imageData: _attachedImageData,
      likes: 0,
      views: 1,
      comments: const [],
      isOfficial: false,
    );

    // Save in our local DB
    await PostDatabaseService.instance.savePost(
      author: post.author,
      handle: post.handle,
      title: post.title,
      body: post.body,
      location: post.location,
      tag: post.tag,
      iconName: _nameFromIcon(post.icon),
      colorHex: _hexFromColor(post.color),
      avatarIndex: profile.avatarIndex,
      customAvatarUrl: post.avatarImageData,
      latitude: _locationAttached ? _lat : template.lat,
      longitude: _locationAttached ? _lng : template.lng,
    );

    ScenarioEngine.instance.overrideLocation(
      post.location,
      lat: _locationAttached ? _lat : template.lat,
      lng: _locationAttached ? _lng : template.lng,
    );

    setState(() {
      _posts = [post, ..._posts];
      _posting = false;
      _attachedImageData = null;
      _locationAttached = false;
      _locationLabel = AppModeService.instance.isDemoMode
          ? 'G-10 Markaz'
          : ScenarioEngine.instance.activeCrisis.location;
      _postController.clear();
    });
  }

  void _selectType(String type) {
    final template = _templates[type]!;
    setState(() {
      _selectedType = type;
      _locationLabel = template.location;
      _lat = template.lat;
      _lng = template.lng;
      _locationAttached = false;
    });
  }

  void _toggleLike(String id) {
    setState(() {
      _posts = _posts.map((post) {
        if (post.id != id) return post;
        return post.copyWith(
          liked: !post.liked,
          likes: post.likes + (post.liked ? -1 : 1),
        );
      }).toList();
    });
  }

  void _addComment(String id, String text) {
    setState(() {
      _posts = _posts.map((post) {
        if (post.id != id) return post;
        return post.copyWith(
          comments: [
            ...post.comments,
            _Comment(author: 'You', handle: '@local_reporter', text: text),
          ],
        );
      }).toList();
    });
  }

  void _openComments(_FeedPost post) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            final livePost = _posts.firstWhere((item) => item.id == post.id);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  18 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.78,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: CiroColors.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${livePost.comments.length} comments',
                              style: const TextStyle(
                                color: CiroColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _CommentPreview(post: livePost),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: livePost.comments.length,
                          itemBuilder: (context, index) {
                            return _CommentTile(
                              comment: livePost.comments[index],
                              color: livePost.color,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              minLines: 1,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Add a helpful update',
                                filled: true,
                                fillColor: CiroColors.bg2,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: CiroColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: CiroColors.border,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _SendButton(
                            onTap: () {
                              final text = controller.text.trim();
                              if (text.isEmpty) return;
                              _addComment(livePost.id, text);
                              controller.clear();
                              setSheet(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<_FeedPost> get _visiblePosts {
    if (_selectedFilter == 'Verified') {
      return _posts
          .where((post) => post.isOfficial || post.tag == 'Verified')
          .toList();
    }
    if (_selectedFilter == 'My posts') {
      final name = UserProfileService.instance.name.trim();
      return _posts
          .where((post) => post.author == 'You' || post.author == name)
          .toList();
    }
    return _posts;
  }

  @override
  Widget build(BuildContext context) {
    final visiblePosts = _visiblePosts;
    return Scaffold(
      backgroundColor: CiroColors.bg1,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
          children: [
            _FeedHeader(
              onBack: () => context.go('/home'),
              onMap: () => context.go('/map'),
            ),
            const SizedBox(height: 14),
            _ComposerCard(
              controller: _postController,
              profile: UserProfileService.instance,
              postLimit: _postLimit,
              selectedType: _selectedType,
              templates: _templates,
              attachedImageData: _attachedImageData,
              locationAttached: _locationAttached,
              locationLabel: _locationLabel,
              posting: _posting,
              onTypeSelected: _selectType,
              onPhoto: _pickPhoto,
              onRemovePhoto: () => setState(() => _attachedImageData = null),
              onLocation: _attachLocation,
              onPost: _publishPost,
            ),
            const SizedBox(height: 16),
            _FilterTabs(
              selected: _selectedFilter,
              onChanged: (value) => setState(() => _selectedFilter = value),
            ),
            const SizedBox(height: 12),
            if (visiblePosts.isEmpty)
              const _EmptyFeed()
            else
              ...visiblePosts.map(
                (post) => _PostCard(
                  post: post,
                  onLike: () => _toggleLike(post.id),
                  onComment: () => _openComments(post),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMap;

  const _FeedHeader({required this.onBack, required this.onMap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crisis Feed',
                style: TextStyle(
                  color: CiroColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Live local reports from people and responders',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CiroColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _IconButton(icon: Icons.map_rounded, onTap: onMap),
      ],
    );
  }
}

class _ComposerCard extends StatelessWidget {
  final TextEditingController controller;
  final UserProfileService profile;
  final int postLimit;
  final String selectedType;
  final Map<String, _CrisisTemplate> templates;
  final String? attachedImageData;
  final bool locationAttached;
  final String locationLabel;
  final bool posting;
  final ValueChanged<String> onTypeSelected;
  final VoidCallback onPhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onLocation;
  final VoidCallback onPost;

  const _ComposerCard({
    required this.controller,
    required this.profile,
    required this.postLimit,
    required this.selectedType,
    required this.templates,
    required this.attachedImageData,
    required this.locationAttached,
    required this.locationLabel,
    required this.posting,
    required this.onTypeSelected,
    required this.onPhoto,
    required this.onRemovePhoto,
    required this.onLocation,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    final template = templates[selectedType]!;
    final photoAttached = attachedImageData != null;
    final displayName = profile.name.trim().isEmpty
        ? 'Local reporter'
        : profile.name.trim();
    final displayRole = profile.role.trim().isEmpty
        ? 'Community crisis report'
        : profile.role.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: CiroColors.borderLight),
        boxShadow: CiroColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ListenableBuilder(
                listenable: UserProfileService.instance,
                builder: (context, _) => _ProfileAvatar(profile: profile, radius: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: postLimit,
                  style: const TextStyle(
                    color: CiroColors.textPrimary,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Report a crisis...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          if (photoAttached) ...[
            const SizedBox(height: 12),
            _AttachedMedia(
              template: template,
              imageData: attachedImageData!,
              onRemove: onRemovePhoto,
            ),
          ],
          const SizedBox(height: 4),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final length = value.text.characters.length;
              final nearLimit = length > postLimit * 0.85;
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$length/$postLimit',
                  style: TextStyle(
                    color: nearLimit
                        ? CiroColors.warning
                        : CiroColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: templates.entries.map((entry) {
                final selected = selectedType == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TypeChip(
                    label: entry.key,
                    icon: entry.value.icon,
                    color: entry.value.color,
                    selected: selected,
                    onTap: () => onTypeSelected(entry.key),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ComposerAction(
                icon: Icons.image_outlined,
                label: photoAttached ? 'Picture added' : 'Upload picture',
                active: photoAttached,
                onTap: onPhoto,
              ),
              const SizedBox(width: 8),
              _ComposerAction(
                icon: Icons.location_on_outlined,
                label: locationAttached ? 'Located' : 'Location',
                active: locationAttached,
                onTap: onLocation,
              ),
              const Spacer(),
              GestureDetector(
                onTap: posting ? null : onPost,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: posting ? CiroColors.textMuted : CiroColors.brand,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: CiroColors.glowCyan,
                  ),
                  alignment: Alignment.center,
                  child: posting
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
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: CiroColors.brand.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: CiroColors.brand.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                _ProfileAvatar(profile: profile, radius: 15),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '$displayName - $displayRole',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CiroColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.public_rounded,
                  color: CiroColors.brand,
                  size: 15,
                ),
              ],
            ),
          ),
          if (locationAttached) ...[
            const SizedBox(height: 10),
            _Pill(
              icon: Icons.my_location_rounded,
              label: locationLabel,
              color: CiroColors.brand,
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterTabs({required this.selected, required this.onChanged});

  static const filters = ['Nearby', 'Verified', 'My posts'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CiroColors.borderLight),
        boxShadow: CiroColors.cardShadow,
      ),
      child: Row(
        children: filters.map((filter) {
          final active = selected == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: active ? CiroColors.brandGradient : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: active ? Colors.white : CiroColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final _FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _card(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: post.color.withValues(alpha: 0.12),
                backgroundImage: post.avatarImageData == null
                    ? null
                    : NetworkImage(post.avatarImageData!),
                child: post.avatarImageData != null
                    ? null
                    : Icon(
                        post.avatarIcon ?? Icons.person_rounded,
                        color: post.avatarColor ?? post.color,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CiroColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (post.isOfficial) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            color: post.color,
                            size: 15,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${post.handle} - ${post.time}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CiroColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _Pill(icon: post.icon, label: post.tag, color: post.color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.body,
            style: const TextStyle(
              color: CiroColors.textPrimary,
              fontSize: 14,
              height: 1.42,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _PostMedia(post: post),
          const SizedBox(height: 12),
          Row(
            children: [
              _SocialAction(
                icon: post.liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: _compactCount(post.likes),
                color: CiroColors.error,
                active: post.liked,
                onTap: onLike,
              ),
              const SizedBox(width: 12),
              _SocialAction(
                icon: Icons.mode_comment_outlined,
                label: _compactCount(post.comments.length),
                color: CiroColors.brand,
                onTap: onComment,
              ),
              const Spacer(),
              _ViewCount(count: post.views),
            ],
          ),
          if (post.comments.isNotEmpty) ...[
            const SizedBox(height: 10),
            _LatestComment(comment: post.comments.last, color: post.color),
          ],
        ],
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  final _FeedPost post;

  const _PostMedia({required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.imageData != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            SizedBox(
              height: 196,
              width: double.infinity,
              child: Image.network(post.imageData!, fit: BoxFit.cover),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: _Pill(
                icon: Icons.location_on_rounded,
                label: post.location,
                color: post.color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 176,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            post.imageTone.withValues(alpha: 0.18),
            CiroColors.bg2,
            post.imageTone.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: post.imageTone.withValues(alpha: 0.18)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -10,
            child: Icon(
              post.icon,
              size: 126,
              color: post.imageTone.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: _Pill(
              icon: Icons.location_on_rounded,
              label: post.location,
              color: post.color,
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: post.color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: post.color.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(post.icon, color: Colors.white, size: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CiroColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'CIRO is comparing this with nearby crisis signals',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CiroColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _AttachedMedia extends StatelessWidget {
  final _CrisisTemplate template;
  final String imageData;
  final VoidCallback onRemove;

  const _AttachedMedia({
    required this.template,
    required this.imageData,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          SizedBox(
            height: 132,
            width: double.infinity,
            child: Image.network(imageData, fit: BoxFit.cover),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Icon(template.icon, color: template.color, size: 16),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${template.title} picture attached',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: template.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
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
  }
}

class _CommentPreview extends StatelessWidget {
  final _FeedPost post;

  const _CommentPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: post.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: post.color.withValues(alpha: 0.14)),
      ),
      child: Text(
        post.body,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: CiroColors.textPrimary,
          fontSize: 12.5,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final _Comment comment;
  final Color color;

  const _CommentTile({required this.comment, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: color.withValues(alpha: 0.10),
            child: Text(
              comment.author.characters.first.toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: CiroColors.bg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CiroColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.author,
                        style: const TextStyle(
                          color: CiroColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        comment.handle,
                        style: const TextStyle(
                          color: CiroColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: const TextStyle(
                      color: CiroColors.textSecondary,
                      fontSize: 12,
                      height: 1.32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestComment extends StatelessWidget {
  final _Comment comment;
  final Color color;

  const _LatestComment({required this.comment, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CiroColors.bg2,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CiroColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.mode_comment_outlined, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${comment.author}: ${comment.text}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CiroColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.11) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? color : CiroColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? color : CiroColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : CiroColors.textPrimary,
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

class _ProfileAvatar extends StatelessWidget {
  final UserProfileService profile;
  final double radius;

  const _ProfileAvatar({required this.profile, required this.radius});

  @override
  Widget build(BuildContext context) {
    final color =
        UserProfileService.avatarColors[profile.avatarIndex.clamp(
          0,
          UserProfileService.avatarColors.length - 1,
        )];
    final icon =
        UserProfileService.avatarIcons[profile.avatarIndex.clamp(
          0,
          UserProfileService.avatarIcons.length - 1,
        )];
    final image = profile.customAvatarUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.12),
      backgroundImage: image == null ? null : NetworkImage(image),
      child: image != null
          ? null
          : Icon(icon, color: color, size: radius * 0.92),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ComposerAction({
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
              ? CiroColors.brand.withValues(alpha: 0.10)
              : CiroColors.bg2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? CiroColors.brand : CiroColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? CiroColors.brand : CiroColors.textSecondary,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? CiroColors.brand : CiroColors.textSecondary,
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

class _SocialAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _SocialAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = active ? color : CiroColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.10) : CiroColors.bg2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, color: display, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: display,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 156),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
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

class _ViewCount extends StatelessWidget {
  final int count;

  const _ViewCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.visibility_outlined,
          color: CiroColors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 5),
        Text(
          _compactCount(count),
          style: const TextStyle(
            color: CiroColors.textMuted,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: CiroColors.brandGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: CiroColors.glowCyan,
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: _card(999),
        child: Icon(icon, color: CiroColors.textPrimary, size: 20),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(24),
      child: const Column(
        children: [
          Icon(Icons.forum_outlined, color: CiroColors.brand, size: 34),
          SizedBox(height: 10),
          Text(
            'No posts here yet',
            style: TextStyle(
              color: CiroColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Post a local crisis update to start this feed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CiroColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _card(double radius) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: CiroColors.borderLight),
  boxShadow: CiroColors.cardShadow,
);

String _compactCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return '$count';
}

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

class _Comment {
  final String author;
  final String handle;
  final String text;

  const _Comment({
    required this.author,
    required this.handle,
    required this.text,
  });
}

class _FeedPost {
  final String id;
  final String author;
  final String handle;
  final String avatarText;
  final String? avatarImageData;
  final Color? avatarColor;
  final IconData? avatarIcon;
  final String time;
  final String title;
  final String body;
  final String location;
  final String tag;
  final IconData icon;
  final Color color;
  final Color imageTone;
  final String? imageData;
  final int likes;
  final int views;
  final bool liked;
  final bool isOfficial;
  final List<_Comment> comments;
  final int shares;
  final int? avatarIndex;

  const _FeedPost({
    required this.id,
    required this.author,
    required this.handle,
    required this.avatarText,
    this.avatarImageData,
    this.avatarColor,
    this.avatarIcon,
    required this.time,
    required this.title,
    required this.body,
    required this.location,
    required this.tag,
    required this.icon,
    required this.color,
    required this.imageTone,
    this.imageData,
    required this.likes,
    required this.views,
    required this.comments,
    required this.isOfficial,
    this.liked = false,
    this.shares = 0,
    this.avatarIndex,
  });

  _FeedPost copyWith({
    int? likes,
    bool? liked,
    List<_Comment>? comments,
    int? shares,
    int? avatarIndex,
  }) {
    return _FeedPost(
      id: id,
      author: author,
      handle: handle,
      avatarText: avatarText,
      avatarImageData: avatarImageData,
      avatarColor: avatarColor,
      avatarIcon: avatarIcon,
      time: time,
      title: title,
      body: body,
      location: location,
      tag: tag,
      icon: icon,
      color: color,
      imageTone: imageTone,
      imageData: imageData,
      likes: likes ?? this.likes,
      views: views,
      liked: liked ?? this.liked,
      comments: comments ?? this.comments,
      isOfficial: isOfficial,
      shares: shares ?? this.shares,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }
}

List<_FeedPost> _seedPosts() => const [
  _FeedPost(
    id: 'post-1',
    author: 'Ayesha Khan',
    handle: '@g10_resident',
    avatarText: 'A',
    time: '4m',
    title: 'Urban flooding',
    body:
        'Water is rising near G-10 Markaz. Smaller cars are slowing down and shop entrances are getting wet.',
    location: 'G-10 Markaz',
    tag: 'Verified',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF2563EB),
    imageTone: Color(0xFF2563EB),
    likes: 42,
    views: 1800,
    isOfficial: false,
    comments: [
      _Comment(
        author: 'CIRO verifier',
        handle: '@ciro',
        text: 'Matched with rainfall and traffic slowdown nearby.',
      ),
      _Comment(
        author: 'Nearby shopkeeper',
        handle: '@markaz_shop',
        text: 'Water is close to the front steps now.',
      ),
    ],
  ),
  _FeedPost(
    id: 'post-2',
    author: 'Traffic Warden Unit',
    handle: '@ict_traffic',
    avatarText: 'T',
    time: '8m',
    title: 'Traffic disruption',
    body:
        'Three nearby road segments are moving below normal speed. Drivers should avoid the service road beside G-10/2.',
    location: 'Service Road West',
    tag: 'Traffic',
    icon: Icons.traffic_rounded,
    color: Color(0xFFF97316),
    imageTone: Color(0xFFF97316),
    likes: 31,
    views: 1420,
    isOfficial: true,
    comments: [
      _Comment(
        author: 'Route Monitor',
        handle: '@ciro_routes',
        text: 'North-side approach is currently safer for responders.',
      ),
    ],
  ),
  _FeedPost(
    id: 'post-3',
    author: 'Relief Desk',
    handle: '@ciro_relief',
    avatarText: 'R',
    time: '12m',
    title: 'Shelter ready',
    body:
        'G-10 Community Center can receive families if water enters homes. Basic meals and first aid are available.',
    location: 'G-10 Community Center',
    tag: 'Ready',
    icon: Icons.home_work_rounded,
    color: Color(0xFF10B981),
    imageTone: Color(0xFF10B981),
    likes: 28,
    views: 980,
    isOfficial: true,
    comments: [
      _Comment(
        author: 'Resident volunteer',
        handle: '@g10_help',
        text: 'We can help guide families from the market side.',
      ),
    ],
  ),
  _FeedPost(
    id: 'post-4',
    author: 'PIMS Emergency Desk',
    handle: '@pims_intake',
    avatarText: 'P',
    time: '15m',
    title: 'Hospital preparedness',
    body:
        'Emergency wing is ready for minor injuries and exposure cases from nearby flooded lanes.',
    location: 'PIMS',
    tag: 'Hospital',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFF0EA5E9),
    imageTone: Color(0xFF0EA5E9),
    likes: 24,
    views: 860,
    isOfficial: true,
    comments: [],
  ),
  _FeedPost(
    id: 'post-5',
    author: 'Field Team 3',
    handle: '@field_ops',
    avatarText: 'F',
    time: '18m',
    title: 'Drainage inspection',
    body:
        'Standing water reported near the market edge. Utility team asked to inspect a possible drain blockage.',
    location: 'G-10/2',
    tag: 'Action',
    icon: Icons.construction_rounded,
    color: Color(0xFF8B5CF6),
    imageTone: Color(0xFF8B5CF6),
    likes: 19,
    views: 730,
    isOfficial: true,
    comments: [
      _Comment(
        author: 'Utility desk',
        handle: '@utility_ops',
        text: 'Crew has been assigned for verification.',
      ),
    ],
  ),
];
