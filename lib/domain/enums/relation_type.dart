enum RelationType { born, battle, ruled, traveled, died, other }

extension RelationTypeHelper on RelationType {
  String get label {
    switch (this) {
      case RelationType.born:
        return '出生于此';
      case RelationType.battle:
        return '作战于此';
      case RelationType.ruled:
        return '治理此地';
      case RelationType.traveled:
        return '途经此地';
      case RelationType.died:
        return '卒于此地';
      case RelationType.other:
        return '关联此地';
    }
  }

  static RelationType fromString(String value) {
    switch (value) {
      case 'born':
        return RelationType.born;
      case 'battle':
        return RelationType.battle;
      case 'ruled':
        return RelationType.ruled;
      case 'traveled':
        return RelationType.traveled;
      case 'died':
        return RelationType.died;
      case 'other':
        return RelationType.other;
      default:
        return RelationType.other;
    }
  }
}
