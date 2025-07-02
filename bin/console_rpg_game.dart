import 'dart:io'; // Library to receive user input from the console
import 'dart:async';
import 'dart:math';

Future<void> main() async {
  // create a FileManager instance and preload all data
  FileManager fileManager = FileManager();
  await fileManager.loadGameData();

  // create a Game object using the loaded data
  Game game = Game();
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

  Game(FileManager fileManager) : all;

  void startGame() {}

  void battle() {}

  void getRandomMonster() {}

  String getCharacterName() {
    while (true) {
      stdout.write('당신을 뭐라고 부를까요? : ');
      String? inputName = stdin.readLineSync();

      // 1. null or empty input
      if (inputName == null || inputName.trim().isEmpty) {
        print('입력되지 않았습니다.');
        continue;
      }

      // 2. 정규표현식 만족 여부
      /* 
      - 이름은 빈 문자열이 아니어야 합니다.
      - 이름에는 **특수문자나 숫자가 포함되지 않아야** 합니다.
      - 허용 문자: **한글, 영문 대소문자**
      */

      if (!RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(inputName)) {
        print('한글, 영문 대소문자만 입력해주세요!');
        continue;
      }

      // 3. 조건 통과: 허용된 캐릭터 이름 입력 완료! return

      print('$inputName !! 멋진 이름이군요! 환영합니다, $inputName님!');
      return inputName;
    }
  }
}

/// //////////////////////////////////////////////////////////
/// Character class definition

class Character {
  String name;
  int hp;
  int attack;
  int defense;

  Character(this.name, this.hp, this.attack, this.defense);

  void attackMonster(Monster monster) {}

  void defend() {}

  void showStatus() {}
}

/// //////////////////////////////////////////////////////////
/// Monster class definition

class Monster {
  String name;
  int hp;
  int attack;
  int defense = 0;

  Monster(this.name, this.hp, this.attack);

  void attackCharacter(Character character) {}

  void showStatus() {}
}
