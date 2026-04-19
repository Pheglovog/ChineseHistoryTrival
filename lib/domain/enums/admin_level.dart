enum AdminLevel { zhou, jun, xian }

extension AdminLevelHelper on AdminLevel {
  String get label {
    switch (this) {
      case AdminLevel.zhou:
        return '州';
      case AdminLevel.jun:
        return '郡';
      case AdminLevel.xian:
        return '县';
    }
  }

  static AdminLevel fromString(String value) {
    switch (value) {
      case 'zhou':
        return AdminLevel.zhou;
      case 'jun':
        return AdminLevel.jun;
      case 'xian':
        return AdminLevel.xian;
      default:
        throw ArgumentError('Unknown AdminLevel value: $value');
    }
  }
}
