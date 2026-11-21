import 'enums.dart';

// Finds the BodyPartName that matches a saved name, ignoring letter case
// Returns null for a name that no longer exists
BodyPartName? parseBodyPart(String value) {
  for (final part in BodyPartName.values) {
    if (part.name.toLowerCase() == value.toLowerCase()) {
      return part;
    }
  }
  return null;
}

// Turns a saved list of names back into BodyPartName values
// A name that no longer exists is skipped, but at least one must remain
List<BodyPartName> readBodyParts(Object? raw) {
  final parts = <BodyPartName>[];
  for (final name in raw as List) {
    final part = parseBodyPart(name.toString());
    if (part != null) parts.add(part);
  }
  if (parts.isEmpty) {
    throw const FormatException('no readable body part');
  }
  return parts;
}
