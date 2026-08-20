class TrendItem {
  final String id;
  final String title;
  final String category;
  final String velocity; // 'Surging', 'Rising', 'Stable'
  final String platform;
  final String recommendedAngle;
  final List<String> hashtags;

  const TrendItem({
    required this.id,
    required this.title,
    required this.category,
    required this.velocity,
    required this.platform,
    required this.recommendedAngle,
    required this.hashtags,
  });
}

/// Trend Intelligence Foundation: Provides an ethical, curated trend radar
/// for platform, niche, and regional creator signals without illegal scraping.
class TrendIntelligenceService {
  TrendIntelligenceService._();

  static const List<TrendItem> curatedTrends = [
    TrendItem(
      id: 'trend_ai_workflows',
      title: 'Local AI & Zero-Prompt Workflows',
      category: 'Tech & AI',
      velocity: 'Surging',
      platform: 'Instagram',
      recommendedAngle: 'Compare manual multi-hour drafting vs intelligent 1-tap creator OS.',
      hashtags: ['#AIWorkflows', '#ProductivityHacks', '#CreatorOS', '#TechTrends'],
    ),
    TrendItem(
      id: 'trend_micro_carousels',
      title: '4-Slide High-Density Carousels',
      category: 'Design & Aesthetics',
      velocity: 'Rising',
      platform: 'LinkedIn',
      recommendedAngle: 'Deliver zero-fluff frameworks with dark aesthetic and bold callouts.',
      hashtags: ['#CreatorEconomy', '#LinkedInGrowth', '#DesignSystems', '#GrowthMarketing'],
    ),
    TrendItem(
      id: 'trend_regional_creators',
      title: 'Regional Dialect Tech Content (Manglish / Hinglish)',
      category: 'Regional Creator Ecosystem',
      velocity: 'Surging',
      platform: 'YouTube',
      recommendedAngle: 'Break down complex developer & AI tools using native regional creator slang.',
      hashtags: ['#KeralaTech', '#TechInMalayalam', '#IndianCreators', '#LearnAI'],
    ),
    TrendItem(
      id: 'trend_behind_scenes',
      title: 'Transparent Builder Journey & Revenue Breakdown',
      category: 'Business & Growth',
      velocity: 'Rising',
      platform: 'Instagram',
      recommendedAngle: 'Show the raw numbers, mistakes, and technical decisions behind your project.',
      hashtags: ['#BuildInPublic', '#IndieHacker', '#CreatorJourney', '#StartupLife'],
    ),
  ];

  static List<TrendItem> getTrendsForNiche(String niche) {
    if (niche.toLowerCase().contains('tech') || niche.toLowerCase().contains('ai')) {
      return curatedTrends.where((t) => t.category == 'Tech & AI' || t.category == 'Regional Creator Ecosystem').toList();
    }
    return curatedTrends;
  }
}
