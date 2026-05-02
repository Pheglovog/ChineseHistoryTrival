enum RouteDifficulty { easy, medium, hard }

extension RouteDifficultyHelper on RouteDifficulty {
  String get label {
    switch (this) {
      case RouteDifficulty.easy:
        return '简单';
      case RouteDifficulty.medium:
        return '中等';
      case RouteDifficulty.hard:
        return '困难';
    }
  }

  static RouteDifficulty fromString(String value) {
    switch (value) {
      case 'easy':
        return RouteDifficulty.easy;
      case 'medium':
        return RouteDifficulty.medium;
      case 'hard':
        return RouteDifficulty.hard;
      default:
        return RouteDifficulty.medium;
    }
  }
}
