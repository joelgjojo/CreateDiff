class DesignTemplate {
  final String id;
  final String name;
  final String style; // 'minimal', 'bold', 'premium'
  final String description;
  final bool isSelected;

  const DesignTemplate({
    required this.id,
    required this.name,
    required this.style,
    required this.description,
    this.isSelected = false,
  });

  DesignTemplate copyWith({
    String? id,
    String? name,
    String? style,
    String? description,
    bool? isSelected,
  }) {
    return DesignTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      style: style ?? this.style,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
