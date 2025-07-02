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
    // Call the internal function to load stats
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

  // Read monster file (private method)
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
///
class Game {
  late Character player;
  List<Monster> allMonsters = [];
  int killedMonsters = 0;

  Game(FileManager fileManager) : allMonsters = fileManager.monsters {
    // Get character name from user input
    String characterName =
        getCharacterName(); // Call the method to get character name
    // Initialize player character with stats from file
    player = Character(
      characterName, //name
      // Use the stats loaded from the file
      fileManager.characterStats[0], //hp
      fileManager.characterStats[1], //attack
      fileManager.characterStats[2], //defense
    );
  }

  void startGame() {
    print('Welcome to the RPG Game!');
    print('Your character: ${player.name}');
    print(
      'HP: ${player.hp}, Attack: ${player.attack}, Defense: ${player.defense}',
    );
    print('Encountered Monsters :');
    for (var monster in allMonsters) {
      print('${monster.name} - HP: ${monster.hp}, Attack: ${monster.attack}');
    }

    print('Let the adventure begin!');
    // Start the game loop
    while (true) {
      print('\n1. Battle a monster');
      print('2. Exit game');
      stdout.write('Choose an option: ');
      String? choice = stdin.readLineSync();
      // Check if the input is null or empty
      if (choice == null || choice.isEmpty) {
        print('No input detected! Please try again.');
        continue;
      }
      // Check if the input is a valid choice
      if (choice == '1') {
        // Start a battle
        battle();
      } else if (choice == '2') {
        // Exit the game
        print('Exiting the game. Goodbye!');
        break;
      } else {
        print('Invalid choice! Please enter 1 or 2.');
        continue;
      }
    }
  }

  void battle() {
    // Get a random monster
    Monster? monster = getRandomMonster();
    if (monster == null) {
      print("There are no more monsters to fight. You won!");
      print('Total monsters defeated: $killedMonsters');
      print('Thank you for playing!');
      return; // Exit if no monsters are available
    }

    // Show the status of the player and the monster
    player.showStatus();
    monster.showStatus();

    // Battle loop
    while (player.isAlive() && monster.isAlive()) {
      print("\n--- Battle Status ---");
      player.showStatus();
      monster.showStatus();
      print("--------------------");

      // Check if the input is null or empty
      // Player's turn to attack
      player.attackMonster(monster);
      if (!monster.isAlive()) {
        killedMonsters++;
        print('You defeated ${monster.name}!');
        break; // Exit the loop if the monster is defeated
      }

      // Monster's turn to attack
      monster.attackCharacter(player);
      if (!player.isAlive()) {
        print('You have been defeated by ${monster.name}!');
        break; // Exit the loop if the player is defeated
      }
    }
  }

  Monster? getRandomMonster() {
    // Check if there are any monsters available
    if (allMonsters.isEmpty) {
      print('All monsters have been defeated!');
      return null;
    }

    // Generate a random index to select a monster
    Random random = Random();
    int randomIndex = random.nextInt(allMonsters.length);

    // Get the monster at the random index
    Monster selectedMonster = allMonsters.removeAt(randomIndex);
    print('A wild ${selectedMonster.name} appears!');
    return selectedMonster;
  }

  String getCharacterName() {
    while (true) {
      stdout.write('What should I call you? : ');
      String? inputName = stdin.readLineSync();

      // 1. null or empty input
      if (inputName == null || inputName.trim().isEmpty) {
        print('No input detected! Please enter a name.');
        continue;
      }

      // 2. 정규표현식 만족 여부
      /* 
      - 이름은 빈 문자열이 아니어야 합니다.
      - 이름에는 **특수문자나 숫자가 포함되지 않아야** 합니다.
      - 허용 문자: **한글, 영문 대소문자**
      */

      if (!RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(inputName)) {
        print('Please use only 한글 or English letters!');
        continue;
      }

      // 3. 조건 통과: 허용된 캐릭터 이름 입력 완료! return
      inputName = inputName.trim(); // Remove leading and trailing spaces

      print('$inputName !! What a great name! Welcome, $inputName!');
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

  /// Method to handle defending against an attack
  /// This method can be overridden by subclasses for specific defense logic
  void defending(int damage) {
    // Basic defense logic
    int actualDamage = max(0, damage - defense);
    hp -= actualDamage;
    print('$name defends against the attack! HP reduced by $actualDamage.');
  }

  /// Method to handle attacking another GameObject
  void attacking(GameObject target) {
    // Basic attack logic
    print('$name attacks ${target.name}!');
    target.defending(attack);
  }

  bool isAlive() {
    return hp > 0;
  }

  // Show the status of the GameObject
  void showingStatus() {
    print('$name - HP: $hp, Attack: $attack, Defense: $defense');
  }
}

/// //////////////////////////////////////////////////////////
/// Character class definition

class Character extends GameObject {
  Character(String name, int hp, int attack, int defense)
    : super(name, hp, attack, defense);

  void attackMonster(Monster monster) {
    // Character attacks the monster
    while (!monster.isAlive() && isAlive()) {
      attacking(monster);
      print('$name attacks ${monster.name}!');
    }

    // Check if the monster is defeated
    if (!monster.isAlive()) {
      print('${monster.name} has been defeated!');
    }
  }

  void defend(Monster monster) {
    // Character defends against the monster's attack
    print('$name is defending against ${monster.name}\'s attack!');
    // Call the defending method from GameObject
    defending(monster.attack);
    // Check if the monster is still alive after the character's attack
    if (!isAlive()) {
      print('$name has been defeated!');
      return; // Exit if the character is defeated
    }
    print('$name has $hp HP left after defending.');
  }

  void showStatus() {
    showingStatus();
  }
}

/// //////////////////////////////////////////////////////////
/// Monster class definition

class Monster extends GameObject {
  Monster(String name, int hp, int attack)
    : super(name, hp, attack, 0); // Monsters typically don't have defense

  void attackCharacter(Character character) {
    // Character attacks the monster
    while (!character.isAlive() && isAlive()) {
      attacking(character);
      print('$name attacks ${character.name}!');
    }

    // Check if the character is defeated
    if (!character.isAlive()) {
      print('You loose!');
    }
  }

  void showStatus() {
    showingStatus();
  }
}
