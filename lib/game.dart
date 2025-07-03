import 'dart:io';
import 'dart:async';
import 'dart:math';

import './models/character.dart';
import './models/monster.dart';
import 'file_manager.dart';
import 'utils.dart';

/// RPG Game class definition

class Game {
  final FileManager fileManager;
  late Character player;
  List<Monster> allMonsters = [];
  int killedMonsters = 0;
  int turnCount = 0;
  bool itemBoosted = false;

  Game(this.fileManager) : allMonsters = fileManager.monsters {
    String characterName =
        getCharacterName(); // Call the method to get character name

    int health = fileManager.characterStats[0];


    // 30% chance to get a health boost
    if (Random().nextDouble() < 0.3) {
      health += 10;
      print(
        '\nYou got a health boost! +10 HP'
        ' (current HP: $health)',
      );
    }

    // Create the player character with stats loaded from the file
    player = Character(
      characterName, //name
      // Use the stats loaded from the file
      health, // hp
      fileManager.characterStats[1], // attack
      fileManager.characterStats[2], // defense
    );
  }

  /// Method to start the game
  /// This method initializes the game, displays the player's stats,
  /// and enters the main game loop where battles with monsters occur.
  Future<void> startGame() async {
    print('\n --- Game Start --- \n');
    print('${player.name}, check your stats:');
    print(
      'HP: ${player.hp}, Attack: ${player.attack}, Defense: ${player.defense}',
    );

// ////////////////////////////////////////////////////////////////////////
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
// end of the main game loop
    
    print('Total monsters defeated: $killedMonsters \n');

    var winORlose = player.isAlive() ? 'Win' : 'Lose';
    fileManager.savingGameResult(winORlose, player, killedMonsters);

    print('Thank you for playing!');
    waitForEnter();
    print('\nExiting the game...\n');
  }


// ////////////////////////////////////////////////////////////////////////
  // battle method to handle the battle logic
  /// This method handles the battle logic between the player and a monster.
  /// It manages turns, player actions (attack, defend, use item), and monster actions.
  /// The battle continues until either the player or the monster is defeated.
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
      turnCount++;
      print('Turn: $turnCount');
      if (turnCount % 3 == 0) {
        // Every 3 turns, monster increases its defense
        monster.increaseDefense(2); // Increase defense by 2
      }
      print('---------------------');

      stdout.write('Choose an action (1: Attack, 2: Defend, 3: Blueberry): ');
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

        // Blueberry item boost
        // Every 3 turns, player can use the item to boost health
        // but can only use it once per monster
        case 3:
          if (!itemBoosted) {
            player.itemBoost(10);
            itemBoosted = true; // Mark item boost as used
          } else {
            print('You have already used the item!');
            print('Please choose again. (1: Attack, 2: Defend)');
            continue;
          }
          break;

        default:
          print('Invalid choice! Please enter 1, 2, or 3.');
          continue;
      }

      if (!monster.isAlive()) {
        print('\n Yayyy!! You defeated ${monster.name}! ');
        killedMonsters++;
        turnCount = 0; // Reset turn count after defeating a monster
        itemBoosted = false; // Reset item boost for the next monster
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

  // ////////////////////////////////////////////////////////////////////
  /// Method to get a random monster from the list of all monsters.
  /// If all monsters have been defeated, it returns null and prints a message.
  /// Returns a [Monster] object or null if no monsters are left.

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
