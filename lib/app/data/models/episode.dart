// ====================================================================
// FILE    : lib/app/data/models/episode.dart
// LAPISAN : Data / Model
//
// GUNANYA :
//   Cetakan untuk satu episode. Hanya butuh nama, tanggal tayang (air_date),
//   dan kode episode (misalnya S01E01).
//
// DIPAKAI OLEH: ApiProvider dan EpisodeController.
// ====================================================================

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
