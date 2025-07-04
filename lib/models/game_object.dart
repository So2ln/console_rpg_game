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
    // Apply damage to the target --> 이거 안하면 자꾸 죽어서 넣음 공격하면서 방어하도록
    target.defending(attack);
    await Future.delayed(Duration(milliseconds: 300));
  }

  bool isAlive() => hp > 0;
}
