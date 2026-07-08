import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:video_player/video_player.dart';

class GuideProfileMediaGrid extends StatelessWidget {
  final GuideProfileEntity profile;

  const GuideProfileMediaGrid({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final mediaItems = _buildMediaItems();

    if (mediaItems.isEmpty) {
      return Padding(
        padding: AppDimens.screenPadding,
        child: _EmptyMediaState(canEdit: profile.canEdit),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimens.screenPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Медиа', style: AppTextStyles.subtitle),
              if (profile.canEdit)
                TextButton(
                  onPressed: () => context.push('/guide/profile/media'),
                  child: Text(
                    'Изменить',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: AppDimens.screenPadding.copyWith(top: 0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: mediaItems.length,
          itemBuilder: (context, index) => mediaItems[index],
        ),
      ],
    );
  }

  List<Widget> _buildMediaItems() {
    final items = <Widget>[];

    // Avatar (always first, like profile pic)
    if (profile.avatarUrl != null) {
      items.add(
        _MediaTile(
          imageUrl: profile.avatarUrl!,
          label: 'Аватар',
          icon: Icons.person,
        ),
      );
    }

    // Presentation video (if exists)
    if (profile.presentationVideoUrl != null) {
      items.add(_VideoTile(videoUrl: profile.presentationVideoUrl!));
    }

    // Car photos placeholder — later you'll add car_photos array from backend
    // For now, if car_model exists, show a placeholder tile
    if (profile.carModel != null && profile.carModel!.isNotEmpty) {
      items.add(
        _InfoTile(
          icon: Icons.directions_car,
          label: profile.carModel!,
          sublabel: profile.carNumber ?? '',
        ),
      );
    }

    return items;
  }
}

class _MediaTile extends StatelessWidget {
  final String imageUrl;
  final String label;
  final IconData icon;

  const _MediaTile({
    required this.imageUrl,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(8),
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoTile extends StatefulWidget {
  final String videoUrl;

  const _VideoTile({required this.videoUrl});

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() => _isInitialized = true);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenVideo(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isInitialized && _controller != null)
              VideoPlayer(_controller!)
            else
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 32,
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                children: const [
                  Icon(Icons.videocam, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Видео',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenVideo(BuildContext context) {
    if (_controller == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (sublabel.isNotEmpty)
            Text(
              sublabel,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyMediaState extends StatelessWidget {
  final bool canEdit;

  const _EmptyMediaState({required this.canEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Нет медиа',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          if (canEdit) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/guide/profile/media'),
              child: const Text('Добавить фото/видео'),
            ),
          ],
        ],
      ),
    );
  }
}
