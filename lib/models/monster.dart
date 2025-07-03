import 'game_object.dart';
import 'character.dart';
import 'package:console_rpg_game/skills/skill_base.dart';
import 'package:console_rpg_game/skills/normal_skill.dart';
import 'package:console_rpg_game/skills/ultimate_skill.dart';

/// Monster class definition

class Monster extends GameObject {
  final String description;
  final String asciiArt;
  final NormalSkill skill;
  final UltimateSkill ultimate;

  bool hasUsedSkill = false;
  bool hasUsedUltimate = false;

  Monster(
    String name,
    int hp,
    int attack,
    int defense,
    this.description,
    this.skill,
    this.ultimate,
    this.asciiArt,
  ) : super(name, hp, attack, defense);

  ///////////////////////////////////////////////////////
  /// Method to use a skill on a target character
  Future<void> useSkillOn(Character target) async {
    skill.applyTo(target);
    hasUsedSkill = true;
  }

  Future<void> useUltimateOn(Character target) async {
    ultimate.applyTo(target);
    hasUsedUltimate = true;
  }

  // ///////////////////////////////////////////////////////
  /// Method to attack a character
  Future<void> attackCharacter(Character character) async {
    await attacking(character);
    if (!character.isAlive()) {
      print('Oh no!!!!');
    }
  }

  // Method to increase the monster's defense
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
