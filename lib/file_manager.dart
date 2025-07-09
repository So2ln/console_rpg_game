import 'dart:io';
import 'package:console_rpg_game/models/character.dart';
import 'skills/normal_skill.dart';
import 'skills/ultimate_skill.dart';
import './models/monster.dart';

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
        final info = line.split('/');
        if (info.length < 5) continue;

        String name = info[0].trim();
        String description = info[1].trim();
        String normalSkillBlock = info[2].trim();
        String ultimateSkillBlock = info[3].trim();
        int attack = int.parse(info[4].trim());
        int hp = int.parse(info[5].trim());

        final normalSkill = _parseNormalSkill(normalSkillBlock);
        final ultimateSkill = _parseUltimateSkill(ultimateSkillBlock);

        // 아스키 파일 불러오기
        String asciiArt = '';

        try {
          final asciiFile = File('assets/ascii/$name.txt');
          asciiArt = await asciiFile.readAsString();
        } catch (e) {
          asciiArt = '(No ASCII art found for $name)';
        }

        monsters.add(
          Monster(
            name,
            hp,
            attack,
            0, //defense is set to 0 for now
            description,
            normalSkill,
            ultimateSkill,
            asciiArt,
          ),
        );
      }
    } catch (e) {
      print('Failed to load monster data: $e');
    }
  }

  // //////////////////////////////////////////////////////////////////////
  // monster skills parsing (private method)
  /// Parses the skill block string and returns a list of Skill objects.
  ///
  /// The skill block is expected to contain lines with the format:
  /// [스킬] SkillName: Description (DebuffType - Value)
  /// [필살기] SkillName: Description (DebuffType - Value)
  ///
  /// Example:
  /// [스킬] 주머니 뒤적거리기: 주머니에서 동전, 먼지, 구겨진 영수증 같은 걸 꺼내 던진다. (공격력 -5)
  /// [필살기] 소원 들어주기(내맘대로): 상대의 소원을 들어주는 척하며 디버프(방어력 -5)를 건다.

  // 1. Parse the normal skill block string and return a NormalSkill object.
  NormalSkill _parseNormalSkill(String block) {
    final skillPattern = RegExp(
      r'\[스킬\]\s*(.*?):\s*(.*?)\((공격력|방어력|체력)[\s]*[-−](\d+)\)',
      dotAll: true,
    );

    final match = skillPattern.firstMatch(block);
    if (match == null) {
      // 파싱 실패 시 기본값 반환
      return NormalSkill('이름없음', '효과 없음');
    }

    return NormalSkill(
      match.group(1)!.trim(), // 스킬 이름
      match.group(2)!.trim(), // 설명
      debuffType: _convertType(match.group(3)!),
      debuffValue: int.parse(match.group(4)!),
    );
  }

  // 2. Parse the ultimate skill block string and return an UltimateSkill object.
  UltimateSkill _parseUltimateSkill(String block) {
    final ultimatePattern = RegExp(
      r'\[필살기\]\s*(.*?):\s*(.*?)\((공격력|방어력|체력)[\s]*[-−](\d+)\)',
      dotAll: true,
    );

    final match = ultimatePattern.firstMatch(block);
    if (match == null) {
      // 파싱 실패 시 기본값 반환
      return UltimateSkill('이름없음', '효과 없음');
    }

    return UltimateSkill(
      match.group(1)!.trim(), // 필살기 이름
      match.group(2)!.trim(), // 설명
      debuffType: _convertType(match.group(3)!),
      debuffValue: int.parse(match.group(4)!),
    );
  }

  // 보조 함수
  String _convertType(String korean) {
    switch (korean) {
      case '공격력':
        return 'attack';
      case '방어력':
        return 'defense';
      case '체력':
        return 'hp';
      default:
        return '';
    }
  }

  // //////////////////////////////////////////////////////////////////////
  /// Saves the game result to a file.

  void savingGameResult(
    String winORlose,
    Character player,
    int killedMonsters,
  ) {
    String? saveChoice;

    while (true) {
      stdout.write('Would you like to save the result? (y/n): ');
      saveChoice = stdin.readLineSync();

      if (saveChoice != null) {
        final choice = saveChoice.toLowerCase();
        if (choice == 'y') {
          File('result.txt').writeAsStringSync(
            'Game Result: You $winORlose !! \n'
            '${player.name} defeated $killedMonsters monster(s). \n'
            'Final Stats: HP: ${player.hp}, Attack: ${player.attack}',
          );
          print('\n Result saved. \n');
          break;
        } else if (choice == 'n') {
          print('\n Result not saved.\n');
          break;
        }
      }

      print('Invalid input! Please enter "y" or "n".');
    }
  }

  /// 류지훈튜터님 gave me feedback to use this function
  /// Returns the character's health from the loaded stats.
  int characterHealth() {
    if (characterStats.isNotEmpty) {
      return characterStats[0]; // Assuming the first element is health
    }
    return 100; // Default health if stats are not loaded
  }
}
