enum MatchSource { manual, ai, geocoding }

extension MatchSourceHelper on MatchSource {
  static MatchSource fromString(String value) {
    switch (value) {
      case 'manual':
        return MatchSource.manual;
      case 'ai':
        return MatchSource.ai;
      case 'geocoding':
        return MatchSource.geocoding;
      default:
        throw ArgumentError('Unknown MatchSource value: $value');
    }
  }
}
