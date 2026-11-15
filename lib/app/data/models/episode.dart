class Episode {
  final int id;
  final String name;
  final String airDate;
  final String code;

  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name']?.toString() ?? '-',
    airDate: json['air_date']?.toString() ?? '-',
    code: json['episode']?.toString() ?? '',
  );
}
