import 'dart:io';
import 'package:console_rpg_game/models/character.dart';

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
        final info = line.split(',');
        String name = info[0];
        int hp = int.parse(info[1]);
        int attack = int.parse(info[2]);

        monsters.add(Monster(name, hp, attack, 0));
      }
    } catch (e) {
      print('Failed to load monster data: $e');
    }
  }

  void savingGameResult(
    String winORlose,
    Character player,
    int killedMonsters,
  ) {
    stdout.write('Would you like to save the result? (y/n): ');
    String? saveChoice = stdin.readLineSync();

    if (saveChoice?.toLowerCase() == 'y') {
      File('result.txt').writeAsStringSync(
        'Game Result: You $winORlose !! \n'
        '${player.name} defeated $killedMonsters monster(s). \n'
        'Final Stats: HP: ${player.hp}, Attack: ${player.attack}',
      );

      print('\n Result saved. \n');
    } else if (saveChoice?.toLowerCase() == 'n') {
      print('\n Result not saved.\n');
    } else {
      print('\n Invalid input! \n Result not saved.\n');
    }
  }
}
