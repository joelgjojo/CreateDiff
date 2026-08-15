# CreateDiff: Custom Code & AI Specifications

This document outlines the complete specifications for all custom Dart code needed in CreateDiff's FlutterFlow project, including Custom Functions, Custom Actions, the AI service layer architecture, mock data, and navigation flow.

---

## SECTION 1: CUSTOM FUNCTIONS

These are pure functions usable in FlutterFlow's Custom Functions section. They do not have imports and execute synchronously.

### 1.1 `getGreeting()`
```dart
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
```

### 1.2 `formatRelativeDate(DateTime date)`
```dart
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  return '${date.day}/${date.month}/${date.year}';
}
```

### 1.3 `getInitials(String name)`
```dart
String getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0][0].toUpperCase();
}
```

### 1.4 `getContentTypesForPlatform(String platform)`
```dart
List<Map<String, String>> getContentTypesForPlatform(String platform) {
  switch (platform.toLowerCase()) {
    case 'instagram':
      return [
        {'type': 'reel', 'label': 'Reel', 'icon': 'movie_filter', 'desc': 'Short-form video content'},
        {'type': 'post', 'label': 'Post', 'icon': 'grid_on', 'desc': 'Feed post with caption'},
        {'type': 'story', 'label': 'Story', 'icon': 'amp_stories', 'desc': '24-hour story content'},
        {'type': 'carousel', 'label': 'Carousel', 'icon': 'view_carousel', 'desc': 'Multi-slide post'},
      ];
    case 'youtube':
      return [
        {'type': 'video', 'label': 'Video', 'icon': 'play_circle', 'desc': 'Long-form video content'},
        {'type': 'short', 'label': 'Short', 'icon': 'short_text', 'desc': 'Vertical short video'},
        {'type': 'community', 'label': 'Community', 'icon': 'forum', 'desc': 'Community post'},
      ];
    case 'linkedin':
      return [
        {'type': 'post', 'label': 'Post', 'icon': 'article', 'desc': 'Professional post'},
        {'type': 'article', 'label': 'Article', 'icon': 'description', 'desc': 'Long-form article'},
      ];
    default:
      return [];
  }
}
```

### 1.5 `getPlatformIcon(String platform)`
```dart
String getPlatformIcon(String platform) {
  switch (platform.toLowerCase()) {
    case 'instagram': return 'camera_alt';
    case 'youtube': return 'play_circle_filled';
    case 'linkedin': return 'work';
    default: return 'public';
  }
}
```

### 1.6 `buildPrompt(...)` — The Zero-Prompt Engine
This is the CORE differentiator. It takes simple user inputs and constructs a structured AI prompt.

```dart
String buildPrompt({
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
  buffer.writeln('Generate professional, platform-optimized content.');
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
  buffer.writeln('Generate the following as a JSON object:');
  
  // Platform-specific output instructions
  if (platform.toLowerCase() == 'instagram') {
    buffer.writeln('1. "hooks": Array of exactly 5 compelling hook options');
    buffer.writeln('2. "caption": A complete, formatted caption with appropriate line breaks, emoji (${emojiUsage ?? "moderate"}), and structure');
    buffer.writeln('3. "ctas": Array of 3 call-to-action options${ctaStyle != null ? " (style: $ctaStyle)" : ""}');
    buffer.writeln('4. "hashtags_high_reach": Array of 5 broad hashtags');
    buffer.writeln('5. "hashtags_medium_reach": Array of 5 moderately targeted hashtags');
    buffer.writeln('6. "hashtags_niche": Array of 5 highly specific niche hashtags');
    buffer.writeln('7. "cover_text": Short text (3-6 words) for reel cover or post graphic');
  } else if (platform.toLowerCase() == 'youtube') {
    buffer.writeln('1. "hooks": Array of 5 opening hook options');
    buffer.writeln('2. "caption": A complete video description with sections, timestamps placeholder, and links placeholder');
    buffer.writeln('3. "ctas": Array of 3 CTA options');
    buffer.writeln('4. "hashtags_high_reach": Array of 5 broad tags');
    buffer.writeln('5. "hashtags_medium_reach": Array of 5 medium tags');
    buffer.writeln('6. "hashtags_niche": Array of 5 niche tags');
    buffer.writeln('7. "cover_text": Video title option (compelling, SEO-friendly)');
  } else if (platform.toLowerCase() == 'linkedin') {
    buffer.writeln('1. "hooks": Array of 5 professional opening hook options');
    buffer.writeln('2. "caption": A complete LinkedIn post with professional formatting, line breaks, and structure');
    buffer.writeln('3. "ctas": Array of 3 professional CTA options');
    buffer.writeln('4. "hashtags_high_reach": Array of 3 broad LinkedIn hashtags');
    buffer.writeln('5. "hashtags_medium_reach": Array of 3 industry hashtags');
    buffer.writeln('6. "hashtags_niche": Array of 3 niche hashtags');
    buffer.writeln('7. "cover_text": Post headline or key takeaway');
  }
  
  buffer.writeln('');
  buffer.writeln('Respond ONLY with the JSON object. No markdown, no explanation.');
  
  return buffer.toString();
}
```

---

## SECTION 2: CUSTOM ACTIONS

Async actions that can import packages and handle external logic.

### 2.1 `copyToClipboard`
```dart
// Custom Action: copyToClipboard
// Return type: void
// Parameters: text (String)

import 'package:flutter/services.dart';

Future<void> copyToClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
}
```

### 2.2 `generateMockContent` — Brand-Memory-Aware Mock AI

This is the MVP mock AI service. It accepts the **full creator profile** and produces outputs that visibly reflect the creator's niche, tone, emoji preferences, CTA style, and language.

> **Critical:** The mock output must feel different for different creator profiles. A "Professional/Minimal" tech creator must get different hooks, emoji density, and CTA style than a "Funny/Heavy emoji" food creator. Brand Memory is the differentiator.

```dart
// Custom Action: generateMockContent
// Return type: String (JSON)
// Parameters:
//   platform (String), contentType (String), idea (String),
//   creatorName (String), niche (String), audience (String),
//   tone (String), language (String), emojiUsage (String),
//   ctaStyle (String), brandVoice (String)

import 'dart:convert';
import 'dart:math';

Future<String> generateMockContent(
  String platform,
  String contentType,
  String idea,
  String creatorName,
  String niche,
  String audience,
  String tone,
  String language,
  String emojiUsage,
  String ctaStyle,
  String brandVoice,
) async {
  // Simulate AI generation delay (2-4 seconds)
  await Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(2000)));

  // Determine emoji density from preference
  final emojiMap = {
    'none': '',
    'minimal': ' 👇',
    'moderate': ' 🔥👇',
    'heavy': ' 🤯🔥💡👇✨',
  };
  final emojiSuffix = emojiMap[emojiUsage.toLowerCase()] ?? ' 👇';

  // Generate content influenced by Brand Memory
  final hooks = _generateHooks(idea, tone, language, emojiUsage, niche);
  final caption = _generateCaption(idea, tone, language, emojiUsage, niche, audience, platform, brandVoice);
  final ctas = _generateCTAs(tone, ctaStyle, language, emojiUsage, creatorName);
  final hashtags = _generateHashtags(idea, platform, niche, language);
  final coverText = _generateCoverText(idea, language);

  final result = {
    'hooks': hooks,
    'caption': caption,
    'ctas': ctas,
    'hashtags_high_reach': hashtags['high'],
    'hashtags_medium_reach': hashtags['medium'],
    'hashtags_niche': hashtags['niche'],
    'cover_text': coverText,
  };

  return jsonEncode(result);
}

List<String> _generateHooks(String idea, String tone, String language, String emojiUsage, String niche) {
  final topic = idea.length > 50 ? idea.substring(0, 50) : idea;
  final emoji = emojiUsage == 'none' ? '' : (emojiUsage == 'heavy' ? ' 🤯🔥' : ' 👇');

  // Language-specific hooks
  if (language.toLowerCase() == 'manglish') {
    return [
      'Ithu arinjaal ninte life maarum$emoji',
      'Ee $topic patti aarum parayaatha karyam',
      '$topic — ivide njan sharikkum padichath ithaan$emoji',
      'Njan $topic try cheythappo sambhavichath 😱',
      'Students-nu $topic ariyaathe pattilla$emoji',
    ];
  } else if (language.toLowerCase() == 'malayalam') {
    return [
      'ഇത് അറിഞ്ഞാൽ നിങ്ങളുടെ ജീവിതം മാറും$emoji',
      '$topic — ആരും പറയാത്ത സത്യം',
      '$topic കുറിച്ച് ഞാൻ പഠിച്ച ഏറ്റവും പ്രധാന കാര്യം$emoji',
      'ഈ $topic ട്രിക്ക് എല്ലാവരും അറിയണം$emoji',
      'നിങ്ങൾ ഇപ്പോഴും $topic ചെയ്യാതിരിക്കുകയാണോ?$emoji',
    ];
  } else if (language.toLowerCase() == 'hindi') {
    return [
      'ये जानने के बाद आपकी ज़िन्दगी बदल जाएगी$emoji',
      '$topic के बारे में कोई नहीं बताता ये बात',
      'मैंने $topic try किया और जो हुआ वो unbelievable था$emoji',
      'Students को $topic ज़रूर जानना चाहिए$emoji',
      '$topic — complete beginner\'s guide$emoji',
    ];
  }

  // English hooks — tone-sensitive
  if (tone.toLowerCase() == 'professional' || tone.toLowerCase() == 'minimal') {
    return [
      'What most people get wrong about $topic.',
      'A practical guide to $topic — no fluff.',
      'The framework behind effective $topic.',
      'Why $topic matters more than you think.',
      'Here\'s a structured approach to $topic.',
    ];
  } else if (tone.toLowerCase() == 'funny' || tone.toLowerCase() == 'casual') {
    return [
      'ok but why did nobody tell me about $topic sooner 😭$emoji',
      'me trying $topic for the first time vs. now 🫠',
      'POV: you finally understand $topic and feel invincible$emoji',
      'i spent way too long not knowing about $topic honestly 💀',
      'the way $topic just changed my whole workflow$emoji',
    ];
  } else if (tone.toLowerCase() == 'bold') {
    return [
      'STOP what you\'re doing — $topic changes everything$emoji',
      'If you\'re not using $topic in 2024, you\'re behind.',
      '$topic is the unfair advantage nobody talks about$emoji',
      'This $topic strategy made me 10x more productive.',
      'Warning: once you learn $topic, you can\'t go back$emoji',
    ];
  }

  // Default educational/friendly
  return [
    'Here\'s something about $topic you probably didn\'t know$emoji',
    'I spent weeks learning $topic so you don\'t have to$emoji',
    '$topic explained simply — save this for later$emoji',
    'What I wish someone told me about $topic$emoji',
    'The beginner\'s guide to $topic that actually works$emoji',
  ];
}

String _generateCaption(
  String idea, String tone, String language, String emojiUsage,
  String niche, String audience, String platform, String brandVoice,
) {
  final useEmoji = emojiUsage != 'none';
  final heavyEmoji = emojiUsage == 'heavy';

  // Manglish caption
  if (language.toLowerCase() == 'manglish') {
    return '''Njan $idea ne kurichu deeply padichappol manasilaayi — ithu sharikkum powerful aanu${useEmoji ? ' 💡' : ''}.

Palappozhum nammal ithokke ignore cheyyum, but trust me, ithu game changer aanu.

Enthokke aanu main points:

${useEmoji ? '✅' : '—'} Manual work kuraykkaan ithukond pattum
${useEmoji ? '✅' : '—'} Results sharikkum accurate aanu
${useEmoji ? '✅' : '—'} Innuthanne thudangaam
${useEmoji ? '✅' : '—'} Technical background onnum venda
${useEmoji ? '✅' : '—'} Community support adipoli aanu

Njan 3 maasam aayi ith use cheyyunnu, ente workflow full maarippoyi${useEmoji ? ' 🚀' : ''}.

${useEmoji ? '💡' : '→'} Ee post save cheyyoo — pinne nanniyund parayum!

Ningalkku $idea ne kurichu enthu thonnunnu? Comment idu${useEmoji ? ' 👇' : '!'}''';
  }

  // Malayalam caption
  if (language.toLowerCase() == 'malayalam') {
    return '''ഞാൻ $idea നെ കുറിച്ച് ആഴത്തിൽ പഠിച്ചപ്പോൾ മനസ്സിലായി — ഇത് ശരിക്കും ശക്തമാണ്${useEmoji ? ' 💡' : ''}.

പലപ്പോഴും നമ്മൾ ഇതൊക്കെ അവഗണിക്കും, പക്ഷേ trust me, ഇത് game changer ആണ്.

പ്രധാന കാര്യങ്ങൾ:

${useEmoji ? '✅' : '—'} Manual work കുറയ്ക്കാൻ കഴിയും
${useEmoji ? '✅' : '—'} ഫലങ്ങൾ accurate ആണ്
${useEmoji ? '✅' : '—'} ഇന്ന് തന്നെ തുടങ്ങാം
${useEmoji ? '✅' : '—'} Technical background വേണ്ട
${useEmoji ? '✅' : '—'} Community support അടിപൊളിയാണ്

ഞാൻ 3 മാസമായി ഇത് ഉപയോഗിക്കുന്നു, workflow പൂർണമായും മാറി${useEmoji ? ' 🚀' : ''}.

${useEmoji ? '💡' : '→'} ഈ പോസ്റ്റ് save ചെയ്യൂ!

നിങ്ങൾക്ക് $idea നെ കുറിച്ച് എന്ത് തോന്നുന്നു? Comment ചെയ്യൂ${useEmoji ? ' 👇' : '!'}''';
  }

  // Hindi caption
  if (language.toLowerCase() == 'hindi') {
    return '''मैंने $idea के बारे में गहराई से study किया और realize हुआ — ये सच में powerful है${useEmoji ? ' 💡' : ''}.

ज़्यादातर लोग इसे ignore करते हैं, लेकिन believe me, ये game changer है.

Main points:

${useEmoji ? '✅' : '—'} Manual work बहुत कम हो जाता है
${useEmoji ? '✅' : '—'} Results surprisingly accurate हैं
${useEmoji ? '✅' : '—'} आज से ही शुरू कर सकते हो
${useEmoji ? '✅' : '—'} कोई technical background नहीं चाहिए
${useEmoji ? '✅' : '—'} Community support बहुत अच्छा है

मैं 3 महीने से use कर रहा/रही हूँ, workflow पूरा बदल गया${useEmoji ? ' 🚀' : ''}.

${useEmoji ? '💡' : '→'} ये post save करो — बाद में काम आएगा!

आपका $idea के बारे में क्या experience है? Comment करो${useEmoji ? ' 👇' : '!'}''';
  }

  // English — tone-adapted
  if (tone.toLowerCase() == 'professional' || tone.toLowerCase() == 'minimal') {
    return '''I\'ve been researching $idea extensively, and the results are worth sharing.

Here are the key findings:

— Significant reduction in manual effort
— Accuracy that exceeds expectations
— Accessible to anyone, regardless of technical background
— Strong community and documentation
— Measurable impact within weeks

After 3 months of implementation, the workflow improvement has been substantial.

If this resonates with your work, consider saving it for reference.

What has your experience with $idea been like?''';
  } else if (tone.toLowerCase() == 'funny' || tone.toLowerCase() == 'casual') {
    return '''ok so I went deep into $idea and honestly??? WHY did nobody tell me about this sooner${heavyEmoji ? ' 😭🤯💀' : useEmoji ? ' 😭' : ''}

like I\'ve been doing things the hard way this whole time and for WHAT

here\'s what blew my mind:

${useEmoji ? '✅' : '→'} saves you literal HOURS
${useEmoji ? '✅' : '→'} actually works (shocking I know)
${useEmoji ? '✅' : '→'} you can start today for free
${useEmoji ? '✅' : '→'} no tech skills needed (thank god)
${useEmoji ? '✅' : '→'} the community is lowkey amazing

been using this for 3 months and my workflow is unrecognizable (in a good way)${heavyEmoji ? ' 🚀🔥✨' : useEmoji ? ' 🚀' : ''}

save this before you forget${useEmoji ? ' 💾' : ''}

what\'s YOUR experience with $idea?? tell me everything${useEmoji ? ' 👇' : ''}''';
  }

  // Default (educational, friendly, bold)
  return '''I\'ve been exploring $idea and here\'s what I found${useEmoji ? ' 👇' : ''}

Most people don\'t realize how powerful this is.

Here are the key takeaways:

${useEmoji ? '✅' : '—'} It saves you hours of manual work
${useEmoji ? '✅' : '—'} The results are surprisingly accurate
${useEmoji ? '✅' : '—'} Anyone can start using it today
${useEmoji ? '✅' : '—'} It\'s completely free to begin
${useEmoji ? '✅' : '—'} The community support is incredible

The best part? You don\'t need any technical background to get started.

I\'ve been using this for 3 months and it\'s transformed my workflow completely${useEmoji ? ' 🚀' : ''}.

${useEmoji ? '💡' : '→'} Save this post for later — you\'ll thank yourself.

What\'s your experience with $idea? Drop a comment below${useEmoji ? ' 👇' : ''}''';
}

List<String> _generateCTAs(String tone, String ctaStyle, String language, String emojiUsage, String creatorName) {
  final useEmoji = emojiUsage != 'none';

  // Language-specific CTAs
  if (language.toLowerCase() == 'manglish') {
    if (ctaStyle.toLowerCase() == 'question') {
      return [
        'Ningalkku ith helpful aayirunno? Comment idu${useEmoji ? ' 💬' : '!'}',
        'Ee list-il ninne favorite ethaan?${useEmoji ? ' 👇' : ''}',
        'Veere tips ariyumo? Share cheyyoo${useEmoji ? ' 🙌' : '!'}',
      ];
    }
    return [
      'Ee post save cheytho — pinne upakaram aakum${useEmoji ? ' 💾' : '!'}',
      'Follow cheyyoo, daily tips varum${useEmoji ? ' ✨' : '!'}',
      'Oru friend-ine tag cheyyoo, avarkum ariyaanam${useEmoji ? ' 👆' : '!'}',
    ];
  }

  if (language.toLowerCase() == 'malayalam') {
    return [
      'ഈ പോസ്റ്റ് save ചെയ്യൂ — പിന്നീട് ഉപകാരപ്പെടും${useEmoji ? ' 💾' : '!'}',
      'Follow ചെയ്യൂ, daily tips വരും${useEmoji ? ' ✨' : '!'}',
      'ഒരു friend-നെ tag ചെയ്യൂ${useEmoji ? ' 👆' : '!'}',
    ];
  }

  if (language.toLowerCase() == 'hindi') {
    return [
      'ये post save करो — बाद में काम आएगा${useEmoji ? ' 💾' : '!'}',
      'Follow करो daily tips के लिए${useEmoji ? ' ✨' : '!'}',
      'एक friend को tag करो जिन्हें ये जानना चाहिए${useEmoji ? ' 👆' : '!'}',
    ];
  }

  // English — CTA style variations
  if (ctaStyle.toLowerCase() == 'question') {
    return [
      'Which of these resonated most with you?${useEmoji ? ' 💬' : ''}',
      'Have you tried this approach? What happened?${useEmoji ? ' 👇' : ''}',
      'What would you add to this list?${useEmoji ? ' 🤔' : ''}',
    ];
  } else if (ctaStyle.toLowerCase() == 'urgency') {
    return [
      'Save this NOW before it gets buried in your feed${useEmoji ? ' 💾' : '!'}',
      'Don\'t wait — start implementing this today${useEmoji ? ' ⚡' : '!'}',
      'Share this with someone who needs to see it RIGHT NOW${useEmoji ? ' 🔥' : '!'}',
    ];
  } else if (ctaStyle.toLowerCase() == 'subtle') {
    return [
      'Worth bookmarking if this resonates.',
      'More like this on my page, if you\'re interested.',
      'Feel free to share with someone who\'d find this useful.',
    ];
  }

  // Default: direct
  return [
    'Save this for later and share with someone who needs it${useEmoji ? ' 💾' : '!'}',
    'Follow $creatorName for more content like this${useEmoji ? ' ✨' : '!'}',
    'Drop a comment if you found this helpful${useEmoji ? ' 🔥' : '!'}',
  ];
}

Map<String, List<String>> _generateHashtags(String idea, String platform, String niche, String language) {
  final words = idea.toLowerCase().split(' ').where((w) => w.length > 3).toList();
  final keyword = words.isNotEmpty ? words.first : 'content';

  // Add language/region-specific hashtags
  final nicheTag = niche.toLowerCase().replaceAll(' ', '');
  final languageHashtags = <String>[];
  if (language.toLowerCase() == 'malayalam' || language.toLowerCase() == 'manglish') {
    languageHashtags.addAll(['#malayalam', '#kerala', '#malayali', '#keralagram']);
  } else if (language.toLowerCase() == 'hindi') {
    languageHashtags.addAll(['#hindi', '#india', '#desicreator', '#hindicontent']);
  } else if (language.toLowerCase() == 'tamil') {
    languageHashtags.addAll(['#tamil', '#tamilnadu', '#tamilcreator', '#chennaigram']);
  } else if (language.toLowerCase() == 'telugu') {
    languageHashtags.addAll(['#telugu', '#hyderabad', '#telugucreator', '#andhrapradesh']);
  }

  return {
    'high': [
      '#trending', '#viral', '#explore', '#fyp', '#instagood',
    ],
    'medium': [
      '#${keyword}tips', '#${nicheTag}', '#learnon${platform.toLowerCase()}',
      '#dailycontent', '#creatortips',
      ...languageHashtags.take(2),
    ],
    'niche': [
      '#${keyword}mastery', '#${keyword}guide',
      '#${nicheTag}community', '#${keyword}hacks',
      ...languageHashtags.skip(2).take(2),
    ],
  };
}

String _generateCoverText(String idea, String language) {
  if (language.toLowerCase() == 'manglish') {
    final words = idea.split(' ');
    return words.take(4).join(' ').toUpperCase();
  }
  if (language.toLowerCase() == 'malayalam') {
    final words = idea.split(' ');
    return words.take(4).join(' ');
  }
  if (idea.length <= 20) return idea.toUpperCase();
  final words = idea.split(' ');
  return words.take(4).join(' ').toUpperCase();
}
```

### 2.3 `parseGeneratedContent`
```dart
// Custom Action: parseGeneratedContent
// Return type: GeneratedContent (custom data type)
// Parameters: jsonString (String)

import 'dart:convert';

Future<dynamic> parseGeneratedContent(String jsonString) async {
  try {
    final data = jsonDecode(jsonString);
    return data;
  } catch (e) {
    return null;
  }
}
```

### 2.4 `saveContentProject`
```dart
// Custom Action: saveContentProject  
// This manages saving to App State contentHistory list
// Parameters: project (ContentProject JSON), content (GeneratedContent JSON)
// Return type: bool

Future<bool> saveContentProject(String projectJson, String contentJson) async {
  try {
    // In FlutterFlow, this would update the App State list
    // The actual implementation uses FlutterFlow's Update App State action
    // This custom action is only needed if complex serialization is required
    return true;
  } catch (e) {
    return false;
  }
}
```

---

## SECTION 3: AI SERVICE ARCHITECTURE

This represents the replaceable AI service layer in CreateDiff.

### Architecture Diagram
```
FlutterFlow UI
    ↓
buildPrompt() — Custom Function (constructs structured prompt)
    ↓
generateMockContent() — Custom Action (MVP: returns mock data)
    ↓ (future: replace with)
API Call to Backend Proxy — FlutterFlow API Group
    ↓
Backend Proxy (Cloud Function / Edge Function)
    ↓
AI Provider (Gemini / OpenAI / Claude)
```

### Future API Integration Setup
When ready to connect a real AI provider:

1. Create an API Group named `AIService` in FlutterFlow
2. Base URL: your backend proxy URL (e.g., `https://api.creatediff.com`)
3. Create API Call: `generateContent`
   - Method: POST
   - Endpoint: `/api/generate`
   - Headers: `Authorization: Bearer [auth_token]`
   - Body (JSON):
     ```json
     {
       "prompt": "[built prompt from buildPrompt()]",
       "platform": "instagram",
       "content_type": "reel",
       "user_id": "[current user id]"
     }
     ```
   - Response: parse as `GeneratedContent` data type
   - Mark as PRIVATE (server-side proxy)
4. Error handling: check response status, show `CDErrorState` on failure.

### Backend Proxy Concept (Node.js/Cloud Function)
```javascript
// This runs on your server, NOT in the Flutter app
// It keeps API keys secure
exports.generateContent = async (req, res) => {
  const { prompt, platform, content_type, user_id } = req.body;
  
  // Verify authentication
  // Rate limiting
  // Call AI provider
  
  const response = await fetch('https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': process.env.GEMINI_API_KEY, // Server-side only
    },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { temperature: 0.8 },
    }),
  });
  
  const data = await response.json();
  // Parse and format response
  // Return structured GeneratedContent
  res.json(formattedContent);
};
```

---

## SECTION 4: MOCK CONTENT LIBRARY

These are 5 complete, realistic mock content packs for different scenarios. These can be used during MVP development and demos to test the UI and feel.

### Mock Pack 1: Instagram Reel — "5 AI tools students should know"
*   **Platform**: Instagram (Reel)
*   **Hooks**:
    1. "Stop writing essays manually — try these 5 AI tools instead 🤯"
    2. "5 AI tools your professors don't want you to know about 🤫"
    3. "POV: You just discovered the ultimate student productivity hack."
    4. "Wish I knew about these AI tools in my freshman year..."
    5. "Are you still studying the hard way? Watch this 👇"
*   **Caption**:
    Survive finals week without burning out! 📚✨ 
    
    If you're a student in 2024, AI is your best friend. But ChatGPT isn't the only tool out there. Here are 5 AI tools that will save you hours of work:
    
    1️⃣ **Notion AI**: The ultimate study planner. Summarizes your lecture notes in seconds.
    2️⃣ **Perplexity AI**: Like Google, but gives you direct answers with academic citations! 
    3️⃣ **Quillbot**: Your personal essay editor. Perfect for rephrasing and flow.
    4️⃣ **Gamma App**: Creates beautiful slide decks from your text in minutes.
    5️⃣ **Mendeley**: Organizes all your research papers automatically.
    
    Don't work harder, work smarter. 🧠
    
    Which tool are you trying first? Let me know below! 👇
*   **CTAs**:
    1. "Save this for finals week! 💾"
    2. "Tag a friend who needs to see this! 👯‍♀️"
    3. "Follow for more student hacks ✨"
*   **Hashtags**:
    *   *High reach*: `#trending #explore #studentlife #college #fyp`
    *   *Medium reach*: `#studyhacks #aitools #productivity #studenttips #learnoninstagram`
    *   *Niche*: `#notionai #finalsweeksurvival #collegetech #academiclife #studysmart`
*   **Cover Text**: "5 Must-Have AI Student Tools"

### Mock Pack 2: Instagram Post — "Homemade Kerala breakfast recipes"
*   **Platform**: Instagram (Post)
*   **Hooks**:
    1. "Craving authentic Kerala breakfast? 🥥"
    2. "Skip the restaurant, make this Nadan Appam at home! 🥞"
    3. "The secret to the perfect Puttu & Kadala Curry 🍛"
    4. "Nothing beats a Sunday morning in Kerala ✨"
    5. "Breakfast just got an Adipoli upgrade! 🔥"
*   **Caption**:
    There’s nothing quite like the aroma of a traditional Kerala breakfast filling the kitchen on a Sunday morning. 🌴✨
    
    Today we’re making classic Palappam (Lace Hoppers) with rich, spicy Kadala Curry. The trick to getting that perfect crispy edge and soft center? Fermenting the batter overnight with a splash of fresh coconut water! 🥥
    
    Ingredients for the batter:
    🥥 2 cups raw rice (soaked)
    🥥 1 cup grated coconut
    🥥 1/2 tsp yeast
    🥥 Sugar & salt to taste
    
    Swipe 👉 to see the step-by-step cooking process and that glorious golden Kadala Curry! 
    
    Are you Team Appam or Team Puttu? Let’s settle this in the comments! 👇😋
*   **CTAs**:
    1. "Which is your favorite? Let me know below! 💬"
    2. "Save this recipe for your next Sunday breakfast 📌"
    3. "Share with a foodie friend who loves South Indian cuisine! 🥘"
*   **Hashtags**:
    *   *High reach*: `#foodie #breakfast #indianfood #foodstagram #homecooking`
    *   *Medium reach*: `#keralafood #southindiancuisine #appam #keralagram #malayali`
    *   *Niche*: `#nadanfood #keralabreakfast #kadalacurry #palappam #mallufoodie`
*   **Cover Text**: "Authentic Kerala Breakfast"

### Mock Pack 3: YouTube Video — "Complete beginner's guide to freelancing"
*   **Platform**: YouTube (Video)
*   **Hooks**:
    1. "How I made my first $1000 freelancing (Step by Step)"
    2. "Don't start freelancing in 2024 without watching this video."
    3. "The exact blueprint to land your first freelance client."
    4. "Quitting your 9-5? Watch this freelancing guide first."
    5. "Freelancing for Beginners: Everything you NEED to know."
*   **Caption**:
    Want to start freelancing but don't know where to begin? In this video, I break down the exact roadmap I used to go from $0 to full-time income as a freelancer. We cover everything from finding your niche, setting your rates, to landing your first paying client on platforms like Upwork and Fiverr.
    
    TIMESTAMPS:
    0:00 - Intro & My Freelance Journey
    1:45 - Step 1: Choosing a Profitable Niche
    4:20 - Step 2: Creating Your Portfolio (Even with no experience)
    7:15 - Step 3: Setting Your Rates (Don't undercharge!)
    10:30 - Step 4: Finding Your First Client
    14:10 - Bonus Tip: Client Retention
    
    🔗 RESOURCES MENTIONED:
    Download my Free Freelance Starter Kit: [Link Placeholder]
    My favorite portfolio builder: [Link Placeholder]
    
    If you found this helpful, hit that subscribe button for weekly videos on making money online and building a creative business!
*   **CTAs**:
    1. "Subscribe for more tips on building a freelance business 📈"
    2. "Download my free freelance proposal template below 👇"
    3. "Leave a comment: What freelance skill are you learning right now?"
*   **Hashtags**:
    *   *High reach*: `#freelance #makemoneyonline #entrepreneur #workfromhome #career`
    *   *Medium reach*: `#freelancingforbeginners #upworktips #sidehustle #digitalnomad #creatoreconomy`
    *   *Niche*: `#freelanceportfolio #clientacquisition #freelancerlife #pricingstrategy #fiverrtips`
*   **Cover Text**: "Freelancing for Beginners: 0 to $1k"

### Mock Pack 4: LinkedIn Post — "Lessons from building a startup"
*   **Platform**: LinkedIn (Post)
*   **Hooks**:
    1. "90% of startups fail in the first year. Here's why mine didn't."
    2. "Building a startup isn't what it looks like on TechCrunch."
    3. "The hardest lesson I learned going from 0 to 10 employees."
    4. "Stop idolizing the 'hustle culture'. Do this instead."
    5. "3 unconventional lessons from 3 years of bootstrapping."
*   **Caption**:
    Building a startup isn't what it looks like on TechCrunch. It's not all funding rounds and ping-pong tables. 
    
    After 3 years of bootstrapping, here are the 3 hardest lessons I had to learn:
    
    1. Your MVP shouldn't be perfect. 
    If you're not embarrassed by your first release, you launched too late. We spent 4 months perfecting a feature our users didn't even want. Talk to customers first, code second.
    
    2. Hiring for culture > Hiring for skill.
    Brilliant jerks will destroy your team's morale faster than a missed deadline. Train for skills, hire for attitude.
    
    3. Rest is a business strategy.
    Burnout isn't a badge of honor. You can't make critical strategic decisions when you're running on 4 hours of sleep and caffeine. 
    
    Founders, the journey is a marathon, not a sprint. Protect your peace just as much as your runway.
    
    What's the most valuable lesson you've learned in your career so far?
*   **CTAs**:
    1. "What's your biggest business lesson? Drop it in the comments. 👇"
    2. "Share this with a fellow founder who needs to hear it."
    3. "Follow me for weekly insights on bootstrapped startups."
*   **Hashtags**:
    *   *High reach*: `#leadership #startup #entrepreneurship #business #innovation`
    *   *Medium reach*: `#founderjourney #bootstrapping #techstartup #startuplessons #management`
    *   *Niche*: `#saasfounder #mvpdevelopment #hiringtips #burnoutprevention #startuplife`
*   **Cover Text**: "3 Hard Startup Lessons"

### Mock Pack 5: Instagram Story — "Flash sale announcement"
*   **Platform**: Instagram (Story)
*   **Hooks**:
    1. "🚨 FLASH SALE LIVE NOW"
    2. "Don't miss out on 50% off! 💸"
    3. "You asked, we listened... the sale is ON."
    4. "⏰ 24 HOURS ONLY"
    5. "Biggest drop of the season is here 🔥"
*   **Caption**:
    🚨 FLASH SALE ALERT! 🚨
    
    For the next 24 hours only, get 50% OFF our entire premium collection! 
    
    You've been asking for this all month, and it's finally here. Stock is extremely limited and we WILL sell out fast. 
    
    Use code: FLASH50 at checkout.
    
    Swipe up to grab yours before they're gone! 🏃‍♀️💨
*   **CTAs**:
    1. "Tap the link sticker to shop now! 🛍️"
    2. "Reply to this story to claim an extra 10% discount code! 📩"
    3. "Send this to a friend who loves a good deal."
*   **Hashtags**:
    *   *High reach*: `#sale #fashion #shopping #discount #ootd`
    *   *Medium reach*: `#flashsale #boutiqueshopping #limitededition #weekenddeals #shoplocal`
    *   *Niche*: `#premiumcollection #50percentoff #exclusiveoffer #24hoursale #wardrobeupdate`
*   **Cover Text**: "50% OFF - 24 HOURS ONLY"

---

### Mock Pack 6: Instagram Reel — Manglish Tech Content
*   **Platform**: Instagram (Reel)
*   **Language**: Manglish
*   **Tone**: Educational + Casual
*   **Brand Memory**: Creator=TechWithJoel, Niche=Technology, Audience=College students, Emoji=Moderate
*   **Hooks**:
    1. "Ee 5 AI tools illathe nee padikkanda 🤯"
    2. "College students-nu ithokke ariyaathe pattilla 👇"
    3. "Ithu arinjaal nee rich aakum — free AI tools 💰"
    4. "Njan ithuvare kanditta illatha AI trick ivide undu"
    5. "Stop! Ee video kaanaathe scroll cheyyanda 🛑"
*   **Caption**:
    Njan last 6 months aayi AI tools use cheyyunnu study-kkum work-inum — ippo ente workflow full maaripoyi 💡
    
    Ithokke free aanu, athum super powerful:
    
    ✅ Notion AI — Notes organize cheyyaan best
    ✅ Perplexity — Google-ne kalum fast answers with sources
    ✅ Gamma App — Presentations 5 minutes-il ready
    ✅ Quillbot — Essay writing easy aakkum
    ✅ ChatGPT — Doubt clear cheyyaan oru teacher pole
    
    Technical background onnum venda, phone-il thanne use cheyyaam 📱
    
    Ee post save cheytho, exam time-nu munpu upakaram aakum!
    
    Ninakku ettavum ishtapetta tool ethaan? Comment idu 👇
*   **CTAs**:
    1. "Save cheytho — exam kazhinjitt nanniyundu parayum 💾"
    2. "Oru classmate-ine tag cheyyoo, avarkum ariyaanam 👆"
    3. "Follow cheyyoo TechWithJoel, daily tech tips varum ✨"
*   **Hashtags**:
    *   *High reach*: `#trending #viral #explore #fyp #instagood`
    *   *Medium reach*: `#aitoolsforstudents #techmalayalam #keralagram #studyhacks #malayali`
    *   *Niche*: `#keralatech #manglishcreator #collegehacks #malayalamtech #techwithstudents`
*   **Cover Text**: "5 AI TOOLS STUDENTS-NU VENDI"

---

### Mock Pack 7: Instagram Post — Malayalam Food Content
*   **Platform**: Instagram (Post)
*   **Language**: Malayalam
*   **Tone**: Friendly + Warm
*   **Brand Memory**: Creator=AmmayudeAdukkala, Niche=Food, Audience=Home cooks in Kerala, Emoji=Heavy
*   **Hooks**:
    1. "ഈ പുട്ട് recipe try ചെയ്താൽ വേറെ ഒന്നും വേണ്ട 🥥🔥"
    2. "അമ്മയുടെ secret recipe — ഇന്ന് ഞാൻ reveal ചെയ്യുന്നു 😍"
    3. "Kerala breakfast ഇതിലും നല്ലത് ഇല്ല ✨🍛"
    4. "Sunday morning special — Puttu & Kadala Curry 🥰"
    5. "ഈ recipe save ചെയ്യൂ, നിങ്ങൾ thanks പറയും 💯"
*   **Caption**:
    ഒരു നല്ല Kerala breakfast-ന്റെ മണം — ഇതിനേക്കാൾ നല്ല morning ഇല്ല 🌴✨🥥
    
    ഇന്ന് നമ്മൾ ഉണ്ടാക്കുന്നത് classic Puttu & Kadala Curry! 🍛🔥
    
    Puttu perfect ആകാൻ ഉള്ള secret? Rice powder fresh ആയി podi cheyyuka, steam slow aayi cheyyuka 💨
    
    Ingredients:
    🥥 2 cup rice powder (puttu podi)
    🥥 1 cup grated coconut
    🥥 ½ tsp salt
    🥥 Water — avashshyathinu mathram
    
    Kadala Curry:
    🍛 Kadala (chickpeas) — overnight soak cheyyuka
    🍛 Coconut paste
    🍛 Kerala spice mix
    🍛 Curry leaves & coconut oil
    
    Swipe cheyyoo step-by-step kaanaan 👉😋
    
    നിങ്ങൾ Team Puttu ആണോ Team Appam ആണോ? Comment ചെയ്യൂ! 👇🤤
*   **CTAs**:
    1. "ഏത് ആണ് നിങ്ങളുടെ favorite? Comment ചെയ്യൂ! 💬😋"
    2. "ഈ recipe save ചെയ്യൂ next Sunday-ക്ക് 📌✨"
    3. "ഒരു foodie friend-നെ tag ചെയ്യൂ! 🥘👆"
*   **Hashtags**:
    *   *High reach*: `#foodie #breakfast #indianfood #foodstagram #homecooking`
    *   *Medium reach*: `#keralafood #malayalam #puttu #keralagram #malayali`
    *   *Niche*: `#nadanfood #keralabreakfast #kadalacurry #mallufoodie #ammayudeadukkala`
*   **Cover Text**: "Puttu & Kadala Curry 🥥"

---

### Mock Pack 8: Instagram Reel — Hindi Fitness Content
*   **Platform**: Instagram (Reel)
*   **Language**: Hindi
*   **Tone**: Bold + Motivational
*   **Brand Memory**: Creator=FitWithRahul, Niche=Fitness, Audience=Beginners 18-30, Emoji=Moderate
*   **Hooks**:
    1. "Gym जाने से पहले ये 5 mistakes मत करना 🛑"
    2. "Beginners ये ज़रूर देखें — मेरी body ऐसे transform हुई 💪"
    3. "3 महीने में body transformation — complete plan यहाँ है 🔥"
    4. "ये workout ट्रिक्स 99% लोग नहीं जानते"
    5. "Skinny से muscular — मेरी journey और exact plan 👇"
*   **Caption**:
    3 महीने में body transformation possible है — बस ये 5 rules follow करो 💪
    
    मैंने भी एक time पे हर चीज़ गलत करी थी — wrong exercises, wrong diet, no rest.
    
    लेकिन जब मैंने ये 5 rules seriously follow किये, results game-changing थे:
    
    ✅ Progressive overload — हर week weight बढ़ाओ
    ✅ Protein — body weight per kg 1.6g protein खाओ
    ✅ Sleep — 7-8 hours minimum, non-negotiable
    ✅ Consistency — fancy plan से better है regular plan
    ✅ Compound movements — Squat, Deadlift, Bench Press पहले
    
    Supplements बाद में, basics पहले 🧠
    
    ये post save करो, daily याद दिलाएगा 💾
    
    तुम्हारा fitness goal क्या है? Comment करो 👇
*   **CTAs**:
    1. "तुम्हारा goal क्या है? Comment करो 💬"
    2. "ये post save करो — daily motivation मिलेगा 💾"
    3. "Follow करो FitWithRahul — daily fitness tips 💪"
*   **Hashtags**:
    *   *High reach*: `#fitness #gym #workout #motivation #transformation`
    *   *Medium reach*: `#hindifitness #desifitness #india #gymmotivation #bodytransformation`
    *   *Niche*: `#fitwitrahul #beginnerworkout #indianfitness #desigym #musclebuildingtips`
*   **Cover Text**: "3 MONTHS BODY TRANSFORMATION"

---

## SECTION 5: NAVIGATION ARCHITECTURE

Document the complete navigation structure of the CreateDiff FlutterFlow project:

### Nav Shell Pages
*   **Pages showing the bottom nav:** `HomePage`, `HistoryPage`, `ProfilePage`
*   **Pages showing as full-screen (no bottom nav):** `SplashPage`, `OnboardingPage`, `CreatorProfilePage`, `CreatePage`, `ContentResultPage`, `DesignSelectionPage`

### Navigation Actions

| From | Action | To | Transition | Type |
|---|---|---|---|---|
| Splash | Auto (2.5s) | Onboarding or Home | Fade 500ms | Replace |
| Onboarding | Get Started | CreatorProfile | SlideRight 300ms | Replace |
| CreatorProfile | Complete | Home | Fade 400ms | Replace |
| Home | Quick Action tap | Create (with platform) | SlideUp 300ms | Push |
| Home | Recent item tap | ContentResult | SlideRight 300ms | Push |
| Home | Brand card tap | Profile | Tab switch (instant) | Replace |
| Create | Back | Home | SlideDown 300ms | Pop |
| Create | Generate success | ContentResult | SlideRight 300ms | Push |
| ContentResult | Back | Previous | SlideLeft 300ms | Pop |
| ContentResult | Choose Design | DesignSelection | SlideRight 300ms | Push |
| DesignSelection | Back | ContentResult | SlideLeft 300ms | Pop |
| DesignSelection | Use Design | Home | Fade 400ms | Replace all |
| BottomNav | Tab tap | Target tab page | Instant/Fade 200ms | Replace |

*(End of document)*
