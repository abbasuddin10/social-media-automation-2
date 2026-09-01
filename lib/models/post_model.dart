class PostModel {
  final String? id;
  final String videoPath;
  final String caption;
  final bool isAiGenerated;
  final List<String> targetPlatforms;
  final bool isScheduled;
  final DateTime? scheduledTime;

  // YouTube specific fields
  final String? youtubeTitle;
  final String? youtubeDescription;
  final List<String>? youtubeTags;
  final String? youtubePrivacy;

  PostModel({
    this.id,
    required this.videoPath,
    required this.caption,
    required this.isAiGenerated,
    required this.targetPlatforms,
    required this.isScheduled,
    this.scheduledTime,
    this.youtubeTitle,
    this.youtubeDescription,
    this.youtubeTags,
    this.youtubePrivacy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_path': videoPath,
      'caption': caption,
      'is_ai_generated': isAiGenerated,
      'target_platforms': targetPlatforms,
      'is_scheduled': isScheduled,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'youtube_title': youtubeTitle,
      'youtube_description': youtubeDescription,
      'youtube_tags': youtubeTags,
      'youtube_privacy': youtubePrivacy,
    };
  }
}
