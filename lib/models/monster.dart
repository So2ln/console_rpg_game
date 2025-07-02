import 'game_object.dart';
import 'character.dart';

/// Monster class definition

class Monster extends GameObject {
  Monster(String name, int hp, int attack, int defense)
    : super(name, hp, attack, defense);
  // : super(name, hp, attack, 0); // Monsters have no defense

  Future<void> attackCharacter(Character character) async {
    await attacking(character);
    if (!character.isAlive()) {
      print('Oh no!!!!');
    }
  }

  int increaseDefense(int amount) {
    defense += amount;
    print(
      '!!!!!! $name is now more resistant to attacks!! '
      '      +$amount Defense',
    );
    return defense;
  }

  @override
  showStatus();
}
