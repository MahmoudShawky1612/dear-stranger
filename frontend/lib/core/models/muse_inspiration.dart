class MusePaletteColor {
  final String name;
  final String hex;
  const MusePaletteColor({required this.name, required this.hex});
  factory MusePaletteColor.fromJson(Map<String, dynamic> json) {
    return MusePaletteColor(
      name: json['name'] as String? ?? 'Color',
      hex: json['hex'] as String? ?? '#000000',
    );
  }
}

class MuseInspiration {
  final String mood;
  final List<MusePaletteColor> palette;
  final List<String> visualMetaphors;
  final String compositionTip;
  final String musicVibe;

  const MuseInspiration({
    required this.mood,
    required this.palette,
    required this.visualMetaphors,
    required this.compositionTip,
    required this.musicVibe,
  });

  factory MuseInspiration.fromJson(Map<String, dynamic> json) {
    final paletteList = (json['palette'] as List<dynamic>?)
            ?.map((e) => MusePaletteColor.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final metaphorsList = (json['visualMetaphors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return MuseInspiration(
      mood: json['mood'] as String? ?? 'Atmospheric & Deep',
      palette: paletteList,
      visualMetaphors: metaphorsList,
      compositionTip: json['compositionTip'] as String? ?? 'Focus on balanced lighting and texture.',
      musicVibe: json['musicVibe'] as String? ?? 'Gentle lo-fi acoustic sounds.',
    );
  }
}
