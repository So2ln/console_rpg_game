import 'game_object.dart';
import 'character.dart';

/// Monster class definition

class Monster extends GameObject {
  Monster(String name, int hp, int attack)
    : super(name, hp, attack, 0); // Monsters have no defense

  Future<void> attackCharacter(Character character) async {
    await attacking(character);
    if (!character.isAlive()) {
      print('Oh no!!!!');
    }
  }
}
