import 'dart:io';
import 'dart:async';
import 'dart:math';

import './models/character.dart';
import './models/monster.dart';
import 'file_manager.dart';
import 'utils.dart';

/// RPG Game class definition

class Game {
  late Character player;
  List<Monster> allMonsters = [];
  int killedMonsters = 0;

  Game(FileManager fileManager) : allMonsters = fileManager.monsters {
    String characterName =
        getCharacterName(); // Call the method to get character name

    int health = fileManager.characterStats[0];

    // 30% chance to get a health boost
    if (Random().nextDouble() < 0.3) {
      health += 10;
    }
    player = Character(
      characterName, //name
      // Use the stats loaded from the file
      health, // hp
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
