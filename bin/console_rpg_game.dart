import 'dart:io'; // Library to receive user input from the console
import 'dart:async';
import 'dart:math';

void main() {
  Game game = Game();
  game.startGame();
}

/// //////////////////////////////////////////////////////////
/// RPG Game class definition
///
class Game {
  late Character player;
  List<Monster> allMonsters = [];
  int killedMonsters = 0;

  Game();

  void startGame() {
    loadCharacterStats();
    loadMonsterStats();
  }

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

  void loadCharacterStats() async {
    int hp = 0;
    int attack = 0;
    int defense = 0;

    try {
      final characterFile = File('assets/characters.txt');
      final lines = await characterFile.readAsLines();
      if (lines.isEmpty) {
        throw FormatException('Please add the character file!');
      }

      final stats = lines.first.split(',');
      if (stats.length != 3) throw FormatException('Invalid character data');

      hp = int.parse(stats[0]);
      attack = int.parse(stats[1]);
      defense = int.parse(stats[2]);
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
      return; // 오류 발생 시 함수 종료
    }

    String name = getCharacterName();
    player = Character(name, hp, attack, defense);
  }

  void loadMonsterStats() async {
    String name = '';
    int hp = 0;
    int attack = 0;
    try {
      final monsterFile = File('assets/monsters.txt');
      final lines = await monsterFile.readAsLines();
      if (lines.isEmpty) {
        throw FormatException('Please add the monster file!');
      }

      for (var line in lines) {
        final info = line.split(',');
        if (info.length != 3) throw FormatException('Invalid character data');
        name = info[0];
        hp = int.parse(info[1]);
        attack = int.parse(info[2]);

        allMonsters.add(Monster(name, hp, attack));
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      return; // 오류 발생 시 함수 종료
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
