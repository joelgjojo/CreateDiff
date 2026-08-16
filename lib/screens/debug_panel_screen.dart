import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';
import '../services/ai_config.dart';
import '../services/app_state.dart';
import '../components/cd_glass_card.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_atmospheric_background.dart';

/// Hidden Developer Debug Panel for verifying Grok AI connection and runtime observability.
class DebugPanelScreen extends StatefulWidget {
  const DebugPanelScreen({super.key});

  @override
  State<DebugPanelScreen> createState() => _DebugPanelScreenState();
}

class _DebugPanelScreenState extends State<DebugPanelScreen> {
  bool _isTesting = false;
  String? _testResult;

  Future<void> _runConnectionTest() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final appState = AppState.instance;
      final content = await AIService.generateContent(
        platform: 'Instagram',
        contentType: 'Reel',
        idea: 'Quick connection test for developer debug panel',
        profile: appState.profile,
      );

      setState(() {
        _testResult = 'SUCCESS: Received ${content.hooks.length} hooks, ${content.caption.length} chars caption.';
      });
    } on AIServiceException catch (e) {
      setState(() {
        _testResult = 'ERROR (${e.status.name}): ${e.message}\nStatus Code: ${e.statusCode}';
      });
    } catch (e) {
      setState(() {
        _testResult = 'EXCEPTION: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final lastLog = AIService.lastDebugLog;
    final hasKey = AIConfig.hasApiKey;
    final maskedKey = AIConfig.apiKey.isNotEmpty
        ? '${AIConfig.apiKey.substring(0, 6)}...${AIConfig.apiKey.substring(AIConfig.apiKey.length - 4)}'
        : 'Not Configured';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Developer Debug Panel'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CDAtmosphericBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CDSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. AI Provider Status Card
                CDGlassCard(
                  elevated: true,
                  padding: const EdgeInsets.all(CDSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasKey ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                            color: hasKey ? CDColors.success : CDColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: CDSpacing.sm),
                          Text(
                            'AI Provider Configuration',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: CDSpacing.md),
                      _buildDebugRow('Provider', 'xAI Grok'),
                      _buildDebugRow('Model', AIConfig.model),
                      _buildDebugRow('Base URL', AIConfig.baseUrl),
                      _buildDebugRow('API Key Status', hasKey ? 'Configured ($maskedKey)' : 'Missing'),
                    ],
                  ),
                ),
                const SizedBox(height: CDSpacing.lg),

                // 2. Last Request Telemetry
                CDGlassCard(
                  padding: const EdgeInsets.all(CDSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Request Telemetry',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: CDSpacing.md),
                      if (lastLog == null)
                        Text(
                          'No requests made yet during this session.',
                          style: TextStyle(color: CDColors.textMuted(context)),
                        )
                      else ...[
                        _buildDebugRow('Status', lastLog.status.name.toUpperCase()),
                        if (lastLog.statusCode != null)
                          _buildDebugRow('HTTP Status', '${lastLog.statusCode}'),
                        _buildDebugRow('Timestamp', lastLog.timestamp.toIso8601String()),
                        _buildDebugRow('Latency', '${lastLog.durationMs} ms'),
                        _buildDebugRow('Prompt Size', '${lastLog.promptLength} chars'),
                        _buildDebugRow('Response Size', '${lastLog.responseLength} chars'),
                        if (lastLog.errorMessage != null) ...[
                          const SizedBox(height: CDSpacing.xs),
                          Text(
                            'Error Details:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CDColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(CDSpacing.sm),
                            decoration: BoxDecoration(
                              color: CDColors.error.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(CDRadius.small),
                            ),
                            child: Text(
                              lastLog.errorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: CDColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: CDSpacing.lg),

                // 3. Live Test Action
                CDGlassCard(
                  padding: const EdgeInsets.all(CDSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Grok API Test',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: CDSpacing.xs),
                      Text(
                        'Dispatches a real test prompt to verify endpoint connectivity.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: CDColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: CDSpacing.md),
                      CDPrimaryButton(
                        label: 'Test Grok Connection',
                        isLoading: _isTesting,
                        isFullWidth: true,
                        onPressed: _runConnectionTest,
                      ),
                      if (_testResult != null) ...[
                        const SizedBox(height: CDSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(CDSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black45 : Colors.white70,
                            borderRadius: BorderRadius.circular(CDRadius.small),
                            border: Border.all(
                              color: isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle,
                            ),
                          ),
                          child: Text(
                            _testResult!,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: CDColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: CDColors.textMuted(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: CDColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
