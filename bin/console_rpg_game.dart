import 'dart:io'; // Library to receive user input from the console
import 'dart:async';
import 'dart:math';

Future<void> main() async {
  // create a FileManager instance and preload all data
  FileManager fileManager = FileManager();
  await fileManager.loadGameData();

  // create a Game object using the loaded data
  Game game = Game(fileManager);
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

  void startGame() {
    print('\n --- Game Start --- \n');
    print('${player.name}, check your stats:');
    print(
      'HP: ${player.hp}, Attack: ${player.attack}, Defense: ${player.defense}',
    );

    // Main game loop
    while (player.isAlive() && allMonsters.isNotEmpty) {
      battle(); // fight one monster

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
    if (saveChoice?.toLowerCase() == 'y') {
      File('result.txt').writeAsStringSync(
        '${player.name} defeated $killedMonsters monster(s).',
      );
      print('Result saved.');
    } else if (saveChoice?.toLowerCase() == 'n') {
      print('Result not saved.');
    } else {
      print('Invalid input! Result not saved.');
    }
  }

  void battle() {
    Monster? monster = getRandomMonster();
    if (monster == null) return;

    print('\n!!! 야생의 몬스터가 출현하였습니다!!!');
    print('${monster.name.trim()}');

    while (player.isAlive() && monster.isAlive()) {
      print("\n--- Battle Status ---");
      player.showStatus();
      monster.showStatus();
      print("---------------------");

      print("\n${player.name}'s turn");
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
          player.attackMonster(monster);
          break;
        case 2:
          player.defend(monster);
          break;
        default:
          print('Invalid choice! Please enter 1 or 2.');
          continue;
      }

      if (!monster.isAlive()) {
        print('You defeated ${monster.name}!');
        killedMonsters++;
        break;
      }

      print('\n${monster.name}\'s turn');
      monster.attackCharacter(player);

      if (!player.isAlive()) {
        print('You have been defeated by ${monster.name}...');
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

  Future<String> getCharacterName() async {
    while (true) {
      stdout.write('Enter your character name: ');
      String? inputName = stdin.readLineSync();

      if (inputName == null || inputName.trim().isEmpty) {
        print('No input detected! Please enter a name.');
        continue;
      }

      if (!RegExp(r'^[a-zA-Z가-힣 ]+$').hasMatch(inputName)) {
        print('Please use only Korean or English letters!');
        continue;
      }

      inputName = inputName.trim();
      print('$inputName!! What a great name! Welcome, $inputName!\n');
      await Future.delayed(Duration(seconds: 1));

      return inputName;
    }
  }
}

/// //////////////////////////////////////////////////////////
/// Abstract class definition

class GameObject {
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
    print('$name defends and takes $actualDamage damage.');
  }

  void attacking(GameObject target) {
    print('$name attacks ${target.name} for $attack damage.');
    target.defending(attack);
  }

  bool isAlive() => hp > 0;
}

/// //////////////////////////////////////////////////////////
/// Character class definition

class Character extends GameObject {
  Character(String name, int hp, int attack, int defense)
    : super(name, hp, attack, defense);

  void attackMonster(Monster monster) {
    attacking(monster);
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

  void attackCharacter(Character character) {
    attacking(character);
    if (!character.isAlive()) {
      print('You lose!');
    }
  }
}
