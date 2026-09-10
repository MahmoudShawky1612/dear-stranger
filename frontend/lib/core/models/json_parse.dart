int asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String asString(dynamic value, [String fallback = '']) {
  if (value is String) return value;
  if (value == null) return fallback;
  return value.toString();
}

String? asStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

bool asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  return fallback;
}

DateTime? asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return DateTime.tryParse(value.toString());
}

DateTime asDateTimeRequired(dynamic value) =>
    asDateTime(value) ?? DateTime.now();

Map<String, dynamic>? asJsonMap(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries) '${entry.key}': entry.value,
    };
  }
  return null;
}

List<Map<String, dynamic>> asJsonMapList(dynamic value) {
  if (value is! List) return const [];
  return value.map(asJsonMap).whereType<Map<String, dynamic>>().toList();
}

({String uploadUrl, String storageKey}) parseUploadInfo(Map<String, dynamic> json) {
  final uploadUrl = asStringOrNull(json['uploadUrl']);
  final storageKey = asStringOrNull(json['storageKey']);
  if (uploadUrl == null || uploadUrl.isEmpty || storageKey == null || storageKey.isEmpty) {
    throw StateError('Invalid upload URL response');
  }
  return (uploadUrl: uploadUrl, storageKey: storageKey);
}
