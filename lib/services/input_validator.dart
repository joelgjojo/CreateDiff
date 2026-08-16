/// Pure validation result model
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.invalid(this.errorMessage) : isValid = false;
}

/// Client-side input validation and spam protection
class InputValidator {
  InputValidator._();

  static const int minIdeaLength = 3;
  static const int maxIdeaLength = 500;
  static const int minProfileNameLength = 2;
  static const int maxProfileNameLength = 80;

  /// Validates creator idea/prompt text
  static ValidationResult validateIdea(String? raw) {
    if (raw == null) {
      return const ValidationResult.invalid('Please enter an idea or topic.');
    }

    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const ValidationResult.invalid('Idea cannot be empty.');
    }

    if (trimmed.length < minIdeaLength) {
      return ValidationResult.invalid(
        'Idea is too short (minimum $minIdeaLength characters).',
      );
    }

    if (trimmed.length > maxIdeaLength) {
      return ValidationResult.invalid(
        'Idea is too long (maximum $maxIdeaLength characters).',
      );
    }

    // Check for repetitive spam input (e.g. "aaaaaa", "111111111")
    if (trimmed.length >= 8) {
      final firstChar = trimmed[0];
      final isAllSame = trimmed.split('').every((c) => c == firstChar);
      if (isAllSame) {
        return const ValidationResult.invalid(
          'Please enter a meaningful topic or concept.',
        );
      }
    }

    return const ValidationResult.valid();
  }

  /// Validates creator name
  static ValidationResult validateCreatorName(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const ValidationResult.invalid('Creator name is required.');
    }

    final trimmed = raw.trim();
    if (trimmed.length < minProfileNameLength) {
      return ValidationResult.invalid(
        'Name must be at least $minProfileNameLength characters.',
      );
    }

    if (trimmed.length > maxProfileNameLength) {
      return ValidationResult.invalid(
        'Name cannot exceed $maxProfileNameLength characters.',
      );
    }

    return const ValidationResult.valid();
  }
}
