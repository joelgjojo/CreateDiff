import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../models/creator_profile.dart';
import '../models/generated_content.dart';
import 'ai_config.dart';

/// The CreateDiff AI Studio Service.
///
/// Integrates with xAI Grok (e.g. `grok-4.5`) as the production AI provider,
/// with robust fallback to the built-in local creator engine.
class AIService {
  AIService._();

  /// Dedicated CreateDiff Studio System Prompt for xAI Grok.
  static String buildSystemPrompt({required CreatorProfile profile}) {
    final buffer = StringBuffer();
    buffer.writeln('You are the core AI Content Engine for CreateDiff — a premium mobile creator and design studio.');
    buffer.writeln('Your role is to transform simple, raw ideas into complete, high-converting, platform-optimized creator content packs.');
    buffer.writeln('');
    buffer.writeln('=== CREATOR BRAND MEMORY (STRICT CONTEXT) ===');
    buffer.writeln('• Creator / Brand Name: ${profile.creatorName.isNotEmpty ? profile.creatorName : "Creator"}');
    buffer.writeln('• Niche / Domain: ${profile.niche.isNotEmpty ? profile.niche : "General"}');
    buffer.writeln('• Target Audience: ${profile.targetAudience.isNotEmpty ? profile.targetAudience : "General audience"}');
    buffer.writeln('• Brand Voice & Tone: ${profile.tone.isNotEmpty ? profile.tone : "Educational & Engaging"}');
    buffer.writeln('• Primary Language: ${profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : "English"}');
    if (profile.secondaryLanguage.isNotEmpty) {
      buffer.writeln('• Regional / Secondary Dialect: ${profile.secondaryLanguage}');
    }
    if (profile.contentStyle.isNotEmpty) {
      buffer.writeln('• Content Style: ${profile.contentStyle}');
    }
    if (profile.brandDescription.isNotEmpty) {
      buffer.writeln('• Brand Description: ${profile.brandDescription}');
    }
    buffer.writeln('• Preferred CTA Style: ${profile.preferredCTAStyle.isNotEmpty ? profile.preferredCTAStyle : "Direct"}');
    buffer.writeln('• Emoji Density: ${profile.emojiUsage.isNotEmpty ? profile.emojiUsage : "moderate"}');
    buffer.writeln('');
    buffer.writeln('=== STRICT INSTRUCTIONS ===');
    buffer.writeln('1. Deliver output exclusively in valid, parseable JSON format.');
    buffer.writeln('2. Do not wrap the JSON with markdown code blocks (no ```json or ```). Return raw JSON.');
    buffer.writeln('3. Provide exactly 5 distinct, high-impact hooks covering curiosity, contrarian, blueprint, story, and question angles.');
    buffer.writeln('4. Provide a full formatted caption with line breaks, value points, and a strong ending.');
    buffer.writeln('5. Provide 3 action-oriented CTAs aligned with the creator\'s CTA style.');
    buffer.writeln('6. Segment hashtags into 3 reach tiers: high reach (broad discovery), medium reach (niche/topic), and niche/community (highly targeted).');
    buffer.writeln('7. Provide a punchy, high-contrast Cover Text (3-5 uppercase words) suitable for visual design slides.');
    buffer.writeln('8. Provide 3 creative format variations (e.g. Standard, High-Engagement, Story Framework).');
    buffer.writeln('9. Respect the specified language and regional dialect (e.g., Manglish should blend English & Malayalam naturally).');
    buffer.writeln('10. Do NOT invent fictional personal brand facts not given in the Creator Brand Memory.');
    buffer.writeln('');
    buffer.writeln('=== REQUIRED JSON SCHEMA ===');
    buffer.writeln('''{
  "hooks": ["hook 1", "hook 2", "hook 3", "hook 4", "hook 5"],
  "caption": "Full formatted caption with linebreaks...",
  "ctas": ["CTA 1", "CTA 2", "CTA 3"],
  "hashtagsHighReach": ["#tag1", "#tag2", "#tag3", "#tag4", "#tag5"],
  "hashtagsMediumReach": ["#tag1", "#tag2", "#tag3", "#tag4"],
  "hashtagsNiche": ["#tag1", "#tag2", "#tag3"],
  "coverText": "PUNCHY GRAPHIC TITLE",
  "variations": ["Variation 1", "Variation 2", "Variation 3"]
}''');
    return buffer.toString();
  }

  /// Builds user request prompt for the AI model.
  static String buildUserPrompt({
    required String platform,
    required String contentType,
    required String idea,
    String? overrideTone,
    String? overrideLanguage,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Platform: $platform');
    buffer.writeln('Format: $contentType');
    buffer.writeln('Idea / Topic: $idea');
    if (overrideTone != null && overrideTone.isNotEmpty) {
      buffer.writeln('Tone Override: $overrideTone');
    }
    if (overrideLanguage != null && overrideLanguage.isNotEmpty) {
      buffer.writeln('Language Override: $overrideLanguage');
    }
    buffer.writeln('');
    buffer.writeln('Generate the complete structured JSON content pack now:');
    return buffer.toString();
  }

  /// Generates a personalized content pack using xAI Grok (with fallback).
  static Future<GeneratedContent> generateContent({
    required String platform,
    required String contentType,
    required String idea,
    required CreatorProfile profile,
    String? overrideTone,
    String? overrideLanguage,
    String? overrideLength,
  }) async {
    // 1. If xAI Grok API key is available, call the production Grok API
    if (AIConfig.hasApiKey) {
      try {
        final grokResult = await _generateWithGrok(
          platform: platform,
          contentType: contentType,
          idea: idea,
          profile: profile,
          overrideTone: overrideTone,
          overrideLanguage: overrideLanguage,
        );
        if (grokResult != null) {
          return grokResult;
        }
      } catch (_) {
        // Fall through to local generation fallback on error
      }
    }

    // 2. Fallback to the rich local content engine
    return _generateLocalContent(
      platform: platform,
      contentType: contentType,
      idea: idea,
      profile: profile,
      overrideTone: overrideTone,
      overrideLanguage: overrideLanguage,
    );
  }

  /// Calls xAI Grok API (`/chat/completions`) using standard HttpClient.
  static Future<GeneratedContent?> _generateWithGrok({
    required String platform,
    required String contentType,
    required String idea,
    required CreatorProfile profile,
    String? overrideTone,
    String? overrideLanguage,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 25);

    try {
      final uri = Uri.parse('${AIConfig.baseUrl}/chat/completions');
      final request = await client.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${AIConfig.apiKey}');

      final systemPrompt = buildSystemPrompt(profile: profile);
      final userPrompt = buildUserPrompt(
        platform: platform,
        contentType: contentType,
        idea: idea,
        overrideTone: overrideTone,
        overrideLanguage: overrideLanguage,
      );

      final payload = {
        'model': AIConfig.model,
        'temperature': 0.7,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'response_format': {'type': 'json_object'},
      };

      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final jsonMap = jsonDecode(responseBody) as Map<String, dynamic>;

        final choices = jsonMap['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final contentStr = message?['content'] as String?;

          if (contentStr != null && contentStr.isNotEmpty) {
            return _parseStructuredContent(contentStr);
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  /// Parses and validates structured JSON response into a `GeneratedContent` object.
  static GeneratedContent? _parseStructuredContent(String rawContent) {
    try {
      // Strip any accidental markdown formatting if present
      var clean = rawContent.trim();
      if (clean.startsWith('```json')) {
        clean = clean.substring(7);
      } else if (clean.startsWith('```')) {
        clean = clean.substring(3);
      }
      if (clean.endsWith('```')) {
        clean = clean.substring(0, clean.length - 3);
      }
      clean = clean.trim();

      final parsed = jsonDecode(clean) as Map<String, dynamic>;

      final hooks = (parsed['hooks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final caption = parsed['caption']?.toString() ?? '';
      final ctas = (parsed['ctas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final highReach = (parsed['hashtagsHighReach'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final medReach = (parsed['hashtagsMediumReach'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final nicheReach = (parsed['hashtagsNiche'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final coverText = parsed['coverText']?.toString() ?? '';
      final variations = (parsed['variations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

      if (hooks.isNotEmpty && caption.isNotEmpty) {
        return GeneratedContent(
          hooks: hooks,
          caption: caption,
          ctas: ctas.isNotEmpty ? ctas : ['Save this post for later 💾'],
          hashtagsHighReach: highReach,
          hashtagsMediumReach: medReach,
          hashtagsNiche: nicheReach,
          coverText: coverText.isNotEmpty ? coverText : 'READY TO PUBLISH',
          variations: variations.isNotEmpty ? variations : ['Standard Edition'],
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Local creation engine for offline/fallback scenarios.
  static Future<GeneratedContent> _generateLocalContent({
    required String platform,
    required String contentType,
    required String idea,
    required CreatorProfile profile,
    String? overrideTone,
    String? overrideLanguage,
  }) async {
    // Pacing delay (1.6 - 2.4s) for smooth natural feedback
    await Future.delayed(Duration(milliseconds: 1600 + Random().nextInt(800)));

    final tone = overrideTone ?? profile.tone;
    final language = overrideLanguage ?? profile.primaryLanguage;
    final emojiUsage = profile.emojiUsage;
    final ctaStyle = profile.preferredCTAStyle;
    final niche = profile.niche;
    final creatorName = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator';

    final hooks = _generateLocalHooks(idea: idea, tone: tone, language: language, emojiUsage: emojiUsage, platform: platform);
    final caption = _generateLocalCaption(
      idea: idea,
      tone: tone,
      language: language,
      emojiUsage: emojiUsage,
      niche: niche,
      platform: platform,
      contentType: contentType,
      creatorName: creatorName,
    );
    final ctas = _generateLocalCTAs(tone: tone, ctaStyle: ctaStyle, language: language, emojiUsage: emojiUsage, creatorName: creatorName);
    final hashtags = _generateLocalHashtags(idea: idea, platform: platform, niche: niche, language: language);
    final coverText = _generateLocalCoverText(idea: idea, language: language);
    final variations = _generateLocalVariations(idea: idea, tone: tone, language: language);

    return GeneratedContent(
      hooks: hooks,
      caption: caption,
      ctas: ctas,
      hashtagsHighReach: hashtags['high'] ?? [],
      hashtagsMediumReach: hashtags['medium'] ?? [],
      hashtagsNiche: hashtags['niche'] ?? [],
      coverText: coverText,
      variations: variations,
    );
  }

  static List<String> _generateLocalHooks({
    required String idea,
    required String tone,
    required String language,
    required String emojiUsage,
    required String platform,
  }) {
    final topic = idea.length > 45 ? '${idea.substring(0, 45)}...' : idea;
    final emoji = emojiUsage == 'none' ? '' : (emojiUsage == 'heavy' ? ' 🤯🔥' : ' 👇');

    final lang = language.toLowerCase();
    if (lang == 'manglish') {
      return [
        'Ithu arinjaal ninte life maarum$emoji',
        'Ee $topic patti aarum parayaatha karyam...',
        '$topic — ivide njan sharikkum padichath ithaan$emoji',
        'Njan $topic try cheythappo sambhavichath 😱',
        'Students & creators-nu $topic ariyaathe pattilla$emoji',
      ];
    } else if (lang == 'malayalam') {
      return [
        'ഇത് അറിഞ്ഞാൽ നിങ്ങളുടെ ജീവിതം മാറും$emoji',
        '$topic — ആരും പറയാത്ത രഹസ്യങ്ങൾ',
        '$topic കുറിച്ച് ഞാൻ പഠിച്ച ഏറ്റവും പ്രധാന കാര്യം$emoji',
        'ഈ $topic ട്രിക്ക് എല്ലാവരും അറിയണം$emoji',
        'നിങ്ങൾ ഇപ്പോഴും $topic ചെയ്യാതിരിക്കുകയാണോ?$emoji',
      ];
    } else if (lang == 'hindi') {
      return [
        'ये जानने के बाद आपकी सोच बदल जाएगी$emoji',
        '$topic के बारे में कोई नहीं बताता ये बात 🤫',
        'मैंने $topic try किया और जो हुआ वो unbelievable था$emoji',
        'हर creator को $topic ज़रूर जानना चाहिए$emoji',
        '$topic — complete step-by-step blueprint$emoji',
      ];
    }

    final t = tone.toLowerCase();
    if (t == 'professional' || t == 'minimal') {
      return [
        'What high performers understand about $topic.',
        'A practical framework for $topic — zero fluff.',
        'The underlying mechanics behind effective $topic.',
        'Why most strategies for $topic fail in practice.',
        'A systematic approach to $topic you can use today.',
      ];
    } else if (t == 'funny' || t == 'casual') {
      return [
        'ok but why did nobody tell me about $topic sooner 😭$emoji',
        'me trying $topic for the first time vs now 🫠',
        'POV: you finally figured out $topic and feel unstoppable$emoji',
        'i spent way too long doing $topic the hard way honestly 💀',
        'the exact way $topic completely upgraded my workflow$emoji',
      ];
    } else if (t == 'bold') {
      return [
        'STOP scrolling — $topic is the unfair advantage you need$emoji',
        'If you\'re not leveraging $topic in 2026, you\'re falling behind.',
        'The uncomfortable truth about $topic nobody wants to admit.',
        'This exact $topic strategy made me 10x more productive$emoji',
        'Warning: once you master $topic, there is no going back.',
      ];
    }

    return [
      'Here\'s the biggest breakthrough with $topic$emoji',
      'I spent months testing $topic so you don\'t have to.',
      '$topic explained simply — bookmark this for later$emoji',
      'What I wish I knew before diving into $topic$emoji',
      'The beginner-friendly blueprint for $topic that actually works.',
    ];
  }

  static String _generateLocalCaption({
    required String idea,
    required String tone,
    required String language,
    required String emojiUsage,
    required String niche,
    required String platform,
    required String contentType,
    required String creatorName,
  }) {
    final useEmoji = emojiUsage != 'none';
    final heavyEmoji = emojiUsage == 'heavy';
    final lang = language.toLowerCase();

    if (lang == 'manglish') {
      return '''Njan $idea-ne kurichu deeply padichappol manasilaayi — ithu sharikkum game changer aanu${useEmoji ? ' 💡' : ''}.

Palappozhum nammal ithokke ignore cheyyum, but trust me, ithu valare powerful aanu.

Enthokke aanu main points:

${useEmoji ? '✅' : '—'} Manual work valare kuraykkaan ithukond pattum
${useEmoji ? '✅' : '—'} Results sharikkum accurate and professional aanu
${useEmoji ? '✅' : '—'} Innuthanne easy aayi thudangaam
${useEmoji ? '✅' : '—'} Complex technical skills onnum venda
${useEmoji ? '✅' : '—'} Long term-il huge time save cheyyum

Njan ith workflow-il add cheythappol substantial growth kandu${useEmoji ? ' 🚀' : ''}.

${useEmoji ? '💡' : '→'} Ee post save cheyyoo — pinne nanniyund parayum!

Ningalkku $idea-ne kurichu enthu thonnunnu? Drop a comment below${useEmoji ? ' 👇' : '!'}''';
    }

    if (lang == 'malayalam') {
      return '''ഞാൻ $idea-നെ കുറിച്ച് ആഴത്തിൽ മനസ്സിലാക്കിയപ്പോൾ തിരിച്ചറിഞ്ഞു — ഇത് അത്രയും ശക്തമാണ്${useEmoji ? ' 💡' : ''}.

നമ്മൾ പലപ്പോഴും കാണാതെ പോകുന്ന ചില ലളിതമായ കാര്യങ്ങളുണ്ട്, എന്നാൽ ഇവ വലിയ മാറ്റം ഉണ്ടാക്കും.

പ്രധാന കാര്യങ്ങൾ:

${useEmoji ? '✅' : '—'} അനാവശ്യമായ ജോലിഭാരം ലഘൂകരിക്കുന്നു
${useEmoji ? '✅' : '—'} കൂടുതൽ വേഗത്തിലും കൃത്യതയിലും പൂർത്തിയാക്കാം
${useEmoji ? '✅' : '—'} ഇന്ന് തന്നെ ആർക്കും പ്രയോഗിച്ചു തുടങ്ങാം
${useEmoji ? '✅' : '—'} വലിയ സാങ്കേതിക പരിജ്ഞാനം ആവശ്യമില്ല
${useEmoji ? '✅' : '—'} മികച്ച ഫലങ്ങൾ സ്ഥിരമായി നിലനിർത്താം

നിങ്ങളുടെ ദൈനംദിന പ്രക്രിയകളിൽ ഇത് ഉൾപ്പെടുത്തുന്നത് വലിയ പ്രയോജനം ചെയ്യും${useEmoji ? ' 🚀' : ''}.

${useEmoji ? '💡' : '→'} കൂടുതൽ വിവരങ്ങൾക്ക് ഈ പോസ്റ്റ് സേവ് ചെയ്തു വെയ്ക്കൂ!

നിങ്ങളുടെ അഭിപ്രായങ്ങൾ കമന്റിൽ പങ്കുവെക്കൂ${useEmoji ? ' 👇' : '!'}''';
    }

    if (lang == 'hindi') {
      return '''मैंने $idea के बारे में गहराई से research किया और पाया — ये सच में क्रांतिकारी है${useEmoji ? ' 💡' : ''}.

ज़्यादातर लोग इसे miss कर देते हैं, लेकिन सही strategy से बड़ा फ़र्क पड़ता है.

मुख्य बातें:

${useEmoji ? '✅' : '—'} मेहनत आधी और results दोगुने हो जाते हैं
${useEmoji ? '✅' : '—'} कोई भी beginner आज से ही शुरू कर सकता है
${useEmoji ? '✅' : '—'} Time management में सबसे बड़ा boost
${useEmoji ? '✅' : '—'} Consistent growth की guarantee
${useEmoji ? '✅' : '—'} Quality कभी compromise नहीं होती

इसे अपनी daily routine का हिस्सा ज़रूर बनाइए${useEmoji ? ' 🚀' : ''}.

${useEmoji ? '💡' : '→'} इस post को save कर लो — बहुत काम आएगी!

आपका इस बारे में क्या सोचना है? नीचे comment करो${useEmoji ? ' 👇' : '!'}''';
    }

    if (platform.toLowerCase() == 'linkedin') {
      return '''Over the past few months, I've been analyzing $idea across different workflows.

Here are the 4 core principles that create sustainable impact:

1. Systems over brute force
Relying solely on effort leads to diminishing returns. Building structured repeatable frameworks multiplies output.

2. Intentional execution
Prioritize high-leverage activities over reactive tasks. Speed matters, but direction matters more.

3. Measurable feedback loops
Refine iteratively based on real signals rather than assumptions.

4. Compound consistency
Small, daily refinements create exponential separation over a 12-month horizon.

What is the biggest leverage point you've discovered in your current workflow?

Let's discuss in the comments below.''';
    }

    if (platform.toLowerCase() == 'youtube') {
      return '''In this breakdown, we explore everything you need to know about $idea and how to implement it effectively.

TIMESTAMPS:
0:00 - The Core Problem
01:45 - The Step-by-Step Blueprint
04:30 - Common Mistakes to Avoid
07:15 - Real-World Implementation
09:50 - Actionable Takeaways

RESOURCES & LINKS:
• Get the Creator Checklist: [Link Placeholder]
• Join the Community: [Link Placeholder]

If this added value to your creative journey, make sure to like, subscribe, and share with someone who needs this!''';
    }

    if (tone.toLowerCase() == 'professional' || tone.toLowerCase() == 'minimal') {
      return '''A structured breakdown of $idea and why it matters:

Key Observations:
— Significant reduction in wasted effort
— Increased clarity and consistency
— Scalable across different content formats
— Immediate applicability with zero overhead

When implemented systematically, the output quality improves noticeably.

Save this for future reference.''';
    } else if (tone.toLowerCase() == 'funny' || tone.toLowerCase() == 'casual') {
      return '''ok so I went down the rabbit hole on $idea and honestly??? WHY was I doing things the hard way before${heavyEmoji ? ' 😭🤯💀' : useEmoji ? ' 😭' : ''}

here is the real tea:

${useEmoji ? '✨' : '→'} cuts down hours of overthinking
${useEmoji ? '✨' : '→'} actually works on day one
${useEmoji ? '✨' : '→'} no complicated setup needed
${useEmoji ? '✨' : '→'} your future self will literally thank you

bookmark this before you forget${useEmoji ? ' 💾' : ''}

what's your honest take on $idea? tell me everything${useEmoji ? ' 👇' : ''}''';
    }

    return '''I've been exploring $idea and here's what made the biggest difference${useEmoji ? ' 👇' : ''}

Most people overcomplicate this, but the fundamentals are surprisingly straightforward:

${useEmoji ? '✅' : '—'} Focus on high-clarity output
${useEmoji ? '✅' : '—'} Eliminate unnecessary friction points
${useEmoji ? '✅' : '—'} Build a consistent, repeatable habit
${useEmoji ? '✅' : '—'} Measure progress by actual completion

The best part? You can start applying this today with zero extra tools.

${useEmoji ? '💡' : '→'} Save this post for when you need a quick reminder.

What's your current approach to $idea? Drop your thoughts below${useEmoji ? ' 👇' : ''}''';
  }

  static List<String> _generateLocalCTAs({
    required String tone,
    required String ctaStyle,
    required String language,
    required String emojiUsage,
    required String creatorName,
  }) {
    final useEmoji = emojiUsage != 'none';
    final lang = language.toLowerCase();

    if (lang == 'manglish') {
      return [
        'Ee post save cheytho — pinne nalla upakaram aakum${useEmoji ? ' 💾' : '!'}',
        'Follow cheyyoo for more daily creator tips${useEmoji ? ' ✨' : '!'}',
        'Oru friend-ine tag cheyyoo, avarkum ariyaanam${useEmoji ? ' 👆' : '!'}',
      ];
    }
    if (lang == 'malayalam') {
      return [
        'ഈ പോസ്റ്റ് ഇപ്പോൾ തന്നെ സേവ് ചെയ്യൂ${useEmoji ? ' 💾' : '!'}',
        'കൂടുതൽ ക്രിയേറ്റർ ടിപ്പുകൾക്കായി ഫോളോ ചെയ്യൂ${useEmoji ? ' ✨' : '!'}',
        'ഇത് ഉപകാരപ്പെടുന്ന ഒരു സുഹൃത്തിന് ഷെയർ ചെയ്യൂ${useEmoji ? ' 👆' : '!'}',
      ];
    }
    if (lang == 'hindi') {
      return [
        'ये post अभी save कर लो — बाद में काम आएगी${useEmoji ? ' 💾' : '!'}',
        'Daily insights के लिए follow ज़रूर करो${useEmoji ? ' ✨' : '!'}',
        'अपने creator दोस्त को share या tag करो${useEmoji ? ' 👆' : '!'}',
      ];
    }

    final c = ctaStyle.toLowerCase();
    if (c == 'question') {
      return [
        'Which point in this list resonated most with you?${useEmoji ? ' 💬' : ''}',
        'Have you tested this in your workflow? What was your experience?${useEmoji ? ' 👇' : ''}',
        'What would you add to this strategy?${useEmoji ? ' 🤔' : ''}',
      ];
    } else if (c == 'urgency') {
      return [
        'Save this immediately before your next content cycle${useEmoji ? ' 💾' : '!'}',
        'Don\'t wait — apply this framework today${useEmoji ? ' ⚡' : '!'}',
        'Share this with someone who needs this breakthrough right now${useEmoji ? ' 🔥' : '!'}',
      ];
    } else if (c == 'subtle') {
      return [
        'Bookmark this if it aligns with your workflow.',
        'More actionable breakdowns available on the profile.',
        'Feel free to pass this along to someone building in public.',
      ];
    }

    return [
      'Save this for later and share with a fellow creator${useEmoji ? ' 💾' : '!'}',
      'Follow for daily creative studio insights${useEmoji ? ' ✨' : '!'}',
      'Drop a 🔥 in the comments if you found this valuable',
    ];
  }

  static Map<String, List<String>> _generateLocalHashtags({
    required String idea,
    required String platform,
    required String niche,
    required String language,
  }) {
    final words = idea
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((w) => w.length > 3)
        .toList();
    final keyword = words.isNotEmpty ? words.first : 'creator';
    final cleanNiche = niche.toLowerCase().replaceAll(' ', '');

    final regionalTags = <String>[];
    final lang = language.toLowerCase();
    if (lang == 'malayalam' || lang == 'manglish') {
      regionalTags.addAll(['#keralacreators', '#malayalam', '#keralagram', '#malayali']);
    } else if (lang == 'hindi') {
      regionalTags.addAll(['#indiancreators', '#desicreator', '#hindi', '#contentindia']);
    } else if (lang == 'tamil') {
      regionalTags.addAll(['#tamilcreator', '#chennai', '#tamil', '#tamilnadu']);
    } else if (lang == 'telugu') {
      regionalTags.addAll(['#telugucreator', '#hyderabad', '#telugu', '#andhra']);
    }

    return {
      'high': [
        '#creatorstudio',
        '#contentcreation',
        '#explorepage',
        '#trending',
        '#productivity',
      ],
      'medium': [
        '#${keyword}tips',
        '#${cleanNiche}creator',
        '#creatortools',
        '#digitalworkflow',
        if (regionalTags.isNotEmpty) regionalTags[0],
        if (regionalTags.length > 1) regionalTags[1],
      ],
      'niche': [
        '#${keyword}strategy',
        '#${cleanNiche}growth',
        '#contentpack',
        '#creatediff',
        if (regionalTags.length > 2) regionalTags[2],
        if (regionalTags.length > 3) regionalTags[3],
      ],
    };
  }

  static String _generateLocalCoverText({required String idea, required String language}) {
    final words = idea.split(' ').where((w) => w.trim().isNotEmpty).toList();
    final short = words.take(4).join(' ');
    return short.toUpperCase();
  }

  static List<String> _generateLocalVariations({
    required String idea,
    required String tone,
    required String language,
  }) {
    return [
      'Standard Edition (Balanced & Actionable)',
      'High-Engagement Variant (Question-First Hook)',
      'Story-Driven Framework (Narrative & Takeaway)',
    ];
  }
}
