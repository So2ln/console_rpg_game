import '../models/game_object.dart';

abstract class SkillBase {
  String get name;
  String get description;
  String? get debuffType;
  int? get debuffValue;

  void applyTo(GameObject target) {
    if (debuffType == null || debuffValue == null) return;

    switch (debuffType) {
      case 'attack':
        target.attack -= debuffValue!;
        print('${target.name}의 공격력이 $debuffValue만큼 감소했습니다!');
        break;
      case 'defense':
        target.defense -= debuffValue!;
        print('${target.name}의 방어력이 $debuffValue만큼 감소했습니다!');
        break;
      case 'hp':
        target.hp -= debuffValue!;
        print('${target.name}의 체력이 $debuffValue만큼 감소했습니다!');
        break;
    }
  }
}
