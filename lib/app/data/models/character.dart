/// Model karakter Rick and Morty.
///
/// Bentuk JSON hasil [toJson] sengaja dibuat sama dengan bentuk JSON dari API,
/// sehingga [Character.fromJson] bisa dipakai untuk data dari API maupun data
/// favorit yang disimpan di Shared Preferences.
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String origin;
  final String location;
  final String image;
  final int episodeCount;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episodeCount,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    String nested(dynamic value) {
      if (value is Map && value['name'] != null)
        return value['name'].toString();
      return 'unknown';
    }

    final episodes = json['episode'];
    return Character(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'unknown',
      species: json['species']?.toString() ?? '-',
      type: json['type']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '-',
      origin: nested(json['origin']),
      location: nested(json['location']),
      image: json['image']?.toString() ?? '',
      episodeCount: episodes is List
          ? episodes.length
          : (json['episode_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'type': type,
    'gender': gender,
    'origin': {'name': origin},
    'location': {'name': location},
    'image': image,
    'episode_count': episodeCount,
  };
}
