import 'game_object.dart';
import 'monster.dart';

/// Character class definition

class Character extends GameObject {
  Character(String name, int hp, int attack, int defense)
    : super(name, hp, attack, defense);

  Future<void> attackMonster(Monster monster) async {
    await attacking(monster);
    if (!monster.isAlive()) {
      print('${monster.name} has been defeated!');
    }
  }

  void defend(Monster monster) {
    print('$name is defending against ${monster.name}\'s attack!');
    defending(monster.attack);
    if (!isAlive()) {
      print('$name has been defeated!');
    } else {
      print('$name has $hp HP left.');
    }
  }

  void itemBoost(int healthBoost) {
    hp += healthBoost;
    print('...\n you ate blueberries!!! + $healthBoost HP');
    print('$name\'s health is now: $hp HP\n');
  }
}
