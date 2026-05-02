enum HistoryCardCategory { event, figure, culture, geography }

extension HistoryCardCategoryHelper on HistoryCardCategory {
  String get label {
    switch (this) {
      case HistoryCardCategory.event:
        return '事件';
      case HistoryCardCategory.figure:
        return '人物';
      case HistoryCardCategory.culture:
        return '文化';
      case HistoryCardCategory.geography:
        return '地理';
    }
  }

  static HistoryCardCategory fromString(String value) {
    switch (value) {
      case 'event':
        return HistoryCardCategory.event;
      case 'figure':
        return HistoryCardCategory.figure;
      case 'culture':
        return HistoryCardCategory.culture;
      case 'geography':
        return HistoryCardCategory.geography;
      default:
        return HistoryCardCategory.event;
    }
  }
}
