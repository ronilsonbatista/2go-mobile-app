enum PlanningInterest {
  art,
  gastronomy,
  sports,
  architecture,
  outdoor,
  music,
  geekCulture,
  localHistory,
  nature;

  static PlanningInterest fromRaw(String raw) {
    switch (raw.toUpperCase()) {
      case 'ART':
        return PlanningInterest.art;
      case 'GASTRONOMY':
        return PlanningInterest.gastronomy;
      case 'SPORTS':
        return PlanningInterest.sports;
      case 'ARCHITECTURE':
        return PlanningInterest.architecture;
      case 'OUTDOOR':
        return PlanningInterest.outdoor;
      case 'MUSIC':
        return PlanningInterest.music;
      case 'GEEK_CULTURE':
        return PlanningInterest.geekCulture;
      case 'LOCAL_HISTORY':
        return PlanningInterest.localHistory;
      case 'NATURE':
      default:
        return PlanningInterest.nature;
    }
  }

  String toRaw() {
    switch (this) {
      case PlanningInterest.art:
        return 'ART';
      case PlanningInterest.gastronomy:
        return 'GASTRONOMY';
      case PlanningInterest.sports:
        return 'SPORTS';
      case PlanningInterest.architecture:
        return 'ARCHITECTURE';
      case PlanningInterest.outdoor:
        return 'OUTDOOR';
      case PlanningInterest.music:
        return 'MUSIC';
      case PlanningInterest.geekCulture:
        return 'GEEK_CULTURE';
      case PlanningInterest.localHistory:
        return 'LOCAL_HISTORY';
      case PlanningInterest.nature:
        return 'NATURE';
    }
  }
}
