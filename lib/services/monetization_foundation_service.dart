enum CreatorPlanTier {
  free,
  pro,
  studio,
}

class PlanEntitlement {
  final CreatorPlanTier tier;
  final String title;
  final int monthlyGenerationsLimit;
  final bool hasVisualIntelligence;
  final bool hasVoiceFirstCreation;
  final bool hasCampaignPlanner;
  final bool hasBrandIntelligence;
  final bool hasPriorityAiEngine;

  const PlanEntitlement({
    required this.tier,
    required this.title,
    required this.monthlyGenerationsLimit,
    required this.hasVisualIntelligence,
    required this.hasVoiceFirstCreation,
    required this.hasCampaignPlanner,
    required this.hasBrandIntelligence,
    required this.hasPriorityAiEngine,
  });
}

/// Monetization Foundation Service: Defines plan tiers, usage quotas,
/// and SaaS feature gates for future subscription scalability without blocking Phase 4 beta.
class MonetizationFoundationService {
  MonetizationFoundationService._();

  static const Map<CreatorPlanTier, PlanEntitlement> plans = {
    CreatorPlanTier.free: PlanEntitlement(
      tier: CreatorPlanTier.free,
      title: 'Creator Starter',
      monthlyGenerationsLimit: 50,
      hasVisualIntelligence: true,
      hasVoiceFirstCreation: true,
      hasCampaignPlanner: true,
      hasBrandIntelligence: true,
      hasPriorityAiEngine: false,
    ),
    CreatorPlanTier.pro: PlanEntitlement(
      tier: CreatorPlanTier.pro,
      title: 'Creator Pro',
      monthlyGenerationsLimit: 500,
      hasVisualIntelligence: true,
      hasVoiceFirstCreation: true,
      hasCampaignPlanner: true,
      hasBrandIntelligence: true,
      hasPriorityAiEngine: true,
    ),
    CreatorPlanTier.studio: PlanEntitlement(
      tier: CreatorPlanTier.studio,
      title: 'Studio Unlimited',
      monthlyGenerationsLimit: 999999,
      hasVisualIntelligence: true,
      hasVoiceFirstCreation: true,
      hasCampaignPlanner: true,
      hasBrandIntelligence: true,
      hasPriorityAiEngine: true,
    ),
  };

  static PlanEntitlement getEntitlement(CreatorPlanTier tier) {
    return plans[tier] ?? plans[CreatorPlanTier.free]!;
  }

  static bool isFeatureAllowed(CreatorPlanTier tier, String featureKey) {
    final entitlement = getEntitlement(tier);
    switch (featureKey) {
      case 'visual_intelligence':
        return entitlement.hasVisualIntelligence;
      case 'voice_creation':
        return entitlement.hasVoiceFirstCreation;
      case 'campaign_planner':
        return entitlement.hasCampaignPlanner;
      case 'brand_dna':
        return entitlement.hasBrandIntelligence;
      case 'priority_ai':
        return entitlement.hasPriorityAiEngine;
      default:
        return true;
    }
  }
}
