import './models/game_object.dart';

// class Skill {
//   final String name;
//   final String description;
//   final String type; // "damage", "heal", "buff", "debuff"
//   final String target; // "self", "enemy"
//   final String stat; // "attack", "defense", "hp"
//   final int value; // 변경 수치 (+/-)

//   Skill({
//     required this.name,
//     required this.description,
//     required this.type,
//     required this.target,
//     required this.stat,
//     required this.value,
//   });

//   void apply(GameObject target) {
//     switch (stat) {
//       case 'attack':
//         target.attack += value;
//         print('${target.name}의 공격력이 ${value > 0 ? '+' : ''}$value 가 되었습니다!!');
//         break;
//       case 'defense':
//         target.defense += value;
//         print('${target.name}의 방어력이 ${value > 0 ? '+' : ''}$value 가 되었습니다!!');
//         break;
//       case 'hp':
//         target.hp += value;
//         print('${target.name}의 체력이 ${value > 0 ? '+' : ''}$value 가 되었습니다!!');
//         break;
//     }
//   }
// }

class Skill {
  final String name;
  final String description;
  final String? debuffType; // 'attack', 'defense', 'hp' 중 하나
  final int? debuffValue;

  Skill(this.name, this.description, {this.debuffType, this.debuffValue});

  /// skills for debuffing
  void applyTo(GameObject target) {
    if (debuffType == null || debuffValue == null) return;

    switch (debuffType) {
      case 'attack':
        target.attack = (target.attack - debuffValue!).clamp(0, target.attack);
        print('>> ${target.name}의 공격력이 ${debuffValue}만큼 감소했다!');
        break;
      case 'defense':
        target.defense = (target.defense - debuffValue!).clamp(
          0,
          target.defense,
        );
        print('>> ${target.name}의 방어력이 ${debuffValue}만큼 감소했다!');
        break;
      case 'hp':
        target.hp = (target.hp - debuffValue!).clamp(0, target.hp);
        print('>> ${target.name}은 ${debuffValue}만큼 피해를 입었다!');
        break;
    }
  }
}
