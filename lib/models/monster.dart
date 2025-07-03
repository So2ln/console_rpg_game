import 'game_object.dart';
import 'character.dart';
import '../skills.dart';

/// Monster class definition

class Monster extends GameObject {
  final String description;
  final String asciiArt;
  final List<Skill> skills;

  bool hasUsedSkill = false;
  bool hasUsedUltimate = false;

  Monster(
    String name,
    int hp,
    int attack,
    int defense,
    this.description,
    this.skills,
    this.asciiArt,
  ) : super(name, hp, attack, defense);

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
      '\n      +$amount Defense',
    );
    return defense;
  }

  @override
  showStatus();
}
