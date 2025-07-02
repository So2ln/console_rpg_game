import 'dart:math';
import 'dart:async';

/// Abstract class definition

abstract class GameObject {
  String name;
  int hp;
  int attack;
  int defense;

  GameObject(this.name, this.hp, this.attack, this.defense);

  void showStatus() {
    print('$name - HP: $hp, Attack: $attack, Defense: $defense');
  }

  void defending(int damage) {
    int actualDamage = max(0, damage - defense);
    hp -= actualDamage;
    print('$name takes $actualDamage damage.');
  }

  Future<void> attacking(GameObject target) async {
    print('$name attacks ${target.name} for $attack damage.');
    await Future.delayed(Duration(milliseconds: 500));
    target.defending(attack);
    await Future.delayed(Duration(milliseconds: 300));
  }

  bool isAlive() => hp > 0;
}
