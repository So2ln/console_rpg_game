import 'dart:io';
import 'dart:math';

import 'package:console_rpg_game/game.dart';
import 'package:console_rpg_game/utils.dart';
import 'package:console_rpg_game/file_manager.dart';

Future<void> main() async {
  // create a FileManager instance and preload all data
  FileManager fileManager = FileManager();
  await fileManager.loadGameData();

  // create a Game object using the loaded data
  Game game = Game(fileManager);
  // wait for the user to press Enter before starting the game
  print('Game Rules:');
  print('1. You will fight against random monsters.');
  print('2. Choose to attack or defend during your turn.');
  print('3. If you defeat a monster, you can continue to the next one.');
  print('4. The game ends when you are defeated or all monsters are defeated.');
  print('5. You can save your game result at the end.\n');
  waitForEnter();

  game.startGame();
}

/// //////////////////////////////////////////////////////////
/// File management class definition

class FileManager {
  List<int> characterStats =
      []; // Variable to store character stats (e.g., [50, 10, 5])
  List<Monster> monsters = []; // List to store the created monster objects

  /// method to load all game data
  /// (with the details handled in private methods)
  Future<void> loadGameData() async {
    await _loadCharacterStats();
    await _loadMonsterStats();
  }

  // read character file (private method)
  Future<void> _loadCharacterStats() async {
    try {
      final file = File('assets/characters.txt');
      final content = await file.readAsString();
      final stats = content.split(',');

      List<int> temporaryList = [];

      for (String statString in stats) {
        int parsedNum = int.parse(statString);

        temporaryList.add(parsedNum);
      }

      characterStats = temporaryList;
    } catch (e) {
      print('Failed to load character data: $e');
    }
  }

  // read monster file (private method)
  Future<void> _loadMonsterStats() async {
    try {
      final file = File('assets/monsters.txt');
      final lines = await file.readAsLines();

      for (var line in lines) {
        final info = line.split(',');
        String name = info[0];
        int hp = int.parse(info[1]);
        int attack = int.parse(info[2]);

        monsters.add(Monster(name, hp, attack));
      }
    } catch (e) {
      print('Failed to load monster data: $e');
    }
  }
}

/// //////////////////////////////////////////////////////////
/// RPG Game class definition

class Game {
  late Character player;
  List<Monster> allMonsters = [];
  int killedMonsters = 0;

  Game(FileManager fileManager) : allMonsters = fileManager.monsters {
    String characterName =
        getCharacterName(); // Call the method to get character name

    player = Character(
      characterName, //name
      // Use the stats loaded from the file
      fileManager.characterStats[0], // hp
      fileManager.characterStats[1], // attack
      fileManager.characterStats[2], // defense
    );
  }

  Future<void> startGame() async {
    print('\n --- Game Start --- \n');
    print('${player.name}, check your stats:');
    print(
      'HP: ${player.hp}, Attack: ${player.attack}, Defense: ${player.defense}',
    );

    // Main game loop
    while (player.isAlive() && allMonsters.isNotEmpty) {
      await battle(); // fight one monster

      if (!player.isAlive()) break;

      stdout.write('\nWould you like to fight the next monster? (y/n): ');
      String? continueChoice = stdin.readLineSync();
      if (continueChoice?.toLowerCase() != 'y') {
        break;
      }
    }

    print('\nExiting the game.');
    print('Total monsters defeated: $killedMonsters');

    stdout.write('Would you like to save the result? (y/n): ');
    String? saveChoice = stdin.readLineSync();
    var winORlose = player.isAlive() ? 'Win' : 'Lose';

    if (saveChoice?.toLowerCase() == 'y') {
      File('result.txt').writeAsStringSync(
        'Game Result: You $winORlose !! \n'
        '${player.name} defeated $killedMonsters monster(s). \n'
        'Final Stats: HP: ${player.hp}, Attack: ${player.attack}',
      );

      print('\n Result saved. \n');
    } else if (saveChoice?.toLowerCase() == 'n') {
      print('Result not saved.');
    } else {
      print('Invalid input! Result not saved.');
    }
  }

  Future battle() async {
    Monster? monster = getRandomMonster();
    if (monster == null) return;

    print('\n!!! 야생의 몬스터가 출현하였습니다!!!');
    await Future.delayed(Duration(milliseconds: 700));
    print('\n         ${monster.name.trim()} 의 등장!!\n');

    while (player.isAlive() && monster.isAlive()) {
      waitForEnter();
      print("\n--- Battle Status ---");
      player.showStatus();
      monster.showStatus();
      print("---------------------");

      print("\n${player.name}'s turn!");
      stdout.write('Choose an action (1: Attack, 2: Defend): ');
      String? input = stdin.readLineSync();
      if (input == null || input.trim().isEmpty) {
        print('No input! Please try again.');
        continue;
      }

      int choice;
      try {
        choice = int.parse(input.trim());
      } catch (e) {
        print('Invalid input! Please enter 1 or 2.');
        continue;
      }

      switch (choice) {
        case 1:
          await player.attackMonster(monster);
          break;
        case 2:
          player.defend(monster);
          break;
        default:
          print('Invalid choice! Please enter 1 or 2.');
          continue;
      }

      if (!monster.isAlive()) {
        print('\n Yayyy!! You defeated ${monster.name}! ');
        killedMonsters++;
        break;
      }

      waitForEnter();
      print('\n${monster.name}\'s turn...');
      await monster.attackCharacter(player);

      if (!player.isAlive()) {
        print('\n${monster.name} has defeated you!');
        print('Game Over!');
        waitForEnter();

        print('You defeated $killedMonsters monster(s).');
        print('Final Stats: HP: ${player.hp}, Attack: ${player.attack}');
        waitForEnter();
        break;
      }
    }
  }

  Monster? getRandomMonster() {
    if (allMonsters.isEmpty) {
      print('All monsters have been defeated!');
      return null;
    }

    Random random = Random();
    int index = random.nextInt(allMonsters.length);
    Monster monster = allMonsters.removeAt(index);
    return monster;
  }
}

/// //////////////////////////////////////////////////////////
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

/// //////////////////////////////////////////////////////////
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
}

/// //////////////////////////////////////////////////////////
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
