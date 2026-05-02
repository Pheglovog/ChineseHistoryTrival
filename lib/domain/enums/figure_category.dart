enum FigureCategory { emperor, minister, general, scholar, other }

extension FigureCategoryHelper on FigureCategory {
  String get label {
    switch (this) {
      case FigureCategory.emperor:
        return '帝王';
      case FigureCategory.minister:
        return '文臣';
      case FigureCategory.general:
        return '武将';
      case FigureCategory.scholar:
        return '学者';
      case FigureCategory.other:
        return '其他';
    }
  }

  static FigureCategory fromString(String value) {
    switch (value) {
      case 'emperor':
        return FigureCategory.emperor;
      case 'minister':
        return FigureCategory.minister;
      case 'general':
        return FigureCategory.general;
      case 'scholar':
        return FigureCategory.scholar;
      case 'other':
        return FigureCategory.other;
      default:
        return FigureCategory.other;
    }
  }
}
