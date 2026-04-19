enum MatchType { exact, approximate, regional }

extension MatchTypeHelper on MatchType {
  static MatchType fromString(String value) {
    switch (value) {
      case 'exact':
        return MatchType.exact;
      case 'approximate':
        return MatchType.approximate;
      case 'regional':
        return MatchType.regional;
      default:
        throw ArgumentError('Unknown MatchType value: $value');
    }
  }
}
