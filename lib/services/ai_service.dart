import 'dart:async';
import 'dart:math';
import '../models/creator_profile.dart';
import '../models/generated_content.dart';

class AIService {
  /// The Zero-Prompt Engine:
  /// Transforms simple creator inputs into a fully structured AI specification.
  /// (This runs invisibly behind the scenes).
  static String buildPrompt({
    required String platform,
    required String contentType,
    required String idea,
    required String niche,
    required String audience,
    required String tone,
    required String language,
    String? brandVoice,
    String? ctaStyle,
    String? emojiUsage,
    String? contentLength,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('You are CreateDiff\'s content generation engine.');
    buffer.writeln('Generate professional, platform-optimized creator content.');
    buffer.writeln('');
    buffer.writeln('=== CREATOR CONTEXT ===');
    buffer.writeln('Niche: $niche');
    buffer.writeln('Target Audience: $audience');
    buffer.writeln('Tone: $tone');
    buffer.writeln('Language: $language');
    if (brandVoice != null && brandVoice.isNotEmpty) {
      buffer.writeln('Brand Voice: $brandVoice');
    }
    if (emojiUsage != null) {
      buffer.writeln('Emoji Usage: $emojiUsage');
    }
    buffer.writeln('');
    buffer.writeln('=== CONTENT REQUEST ===');
    buffer.writeln('Platform: $platform');
    buffer.writeln('Format: $contentType');
    buffer.writeln('Idea: $idea');
    if (contentLength != null) {
      buffer.writeln('Length: $contentLength');
    }
    buffer.writeln('');
    buffer.writeln('=== OUTPUT FORMAT ===');
    buffer.writeln('Generate structured JSON with hooks, caption, ctas, hashtags (high, medium, niche), coverText, and variations.');
    return buffer.toString();
  }

  /// Generates a complete, personalized, platform-optimized Content Pack
  /// directly influenced by the CreatorProfile (Brand Memory).
  static Future<GeneratedContent> generateContent({
    required String platform,
    required String contentType,
    required String idea,
    required CreatorProfile profile,
    String? overrideTone,
    String? overrideLanguage,
    String? overrideLength,
  }) async {
    // Simulate generation latency (1.8 - 2.8s) for smooth visual pacing
    await Future.delayed(Duration(milliseconds: 1800 + Random().nextInt(1000)));

    final tone = overrideTone ?? profile.tone;
    final language = overrideLanguage ?? profile.primaryLanguage;
    final emojiUsage = profile.emojiUsage;
    final ctaStyle = profile.preferredCTAStyle;
    final niche = profile.niche;
    final creatorName = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator';

    final hooks = _generateHooks(idea: idea, tone: tone, language: language, emojiUsage: emojiUsage, platform: platform);
    final caption = _generateCaption(
      idea: idea,
      tone: tone,
      language: language,
      emojiUsage: emojiUsage,
      niche: niche,
      platform: platform,
      contentType: contentType,
      creatorName: creatorName,
    );
    final ctas = _generateCTAs(tone: tone, ctaStyle: ctaStyle, language: language, emojiUsage: emojiUsage, creatorName: creatorName);
    final hashtags = _generateHashtags(idea: idea, platform: platform, niche: niche, language: language);
    final coverText = _generateCoverText(idea: idea, language: language);
    final variations = _generateVariations(idea: idea, tone: tone, language: language);

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

  static List<String> _generateHooks({
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

    // English - Tone sensitive
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

    // Default: Educational / Friendly
    return [
      'Here\'s the biggest breakthrough with $topic$emoji',
      'I spent months testing $topic so you don\'t have to.',
      '$topic explained simply — bookmark this for later$emoji',
      'What I wish I knew before diving into $topic$emoji',
      'The beginner-friendly blueprint for $topic that actually works.',
    ];
  }

  static String _generateCaption({
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

    // Platform-specific English captions
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

    // Instagram / Default
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

  static List<String> _generateCTAs({
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

  static Map<String, List<String>> _generateHashtags({
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

  static String _generateCoverText({required String idea, required String language}) {
    final words = idea.split(' ').where((w) => w.trim().isNotEmpty).toList();
    final short = words.take(4).join(' ');
    return short.toUpperCase();
  }

  static List<String> _generateVariations({
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
