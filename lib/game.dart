import 'dart:io';
import 'dart:async';
import 'dart:math';

import './models/character.dart';
import './models/monster.dart';
import 'package:console_rpg_game/file_manager.dart';
import 'package:console_rpg_game/utils.dart';

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
      health += 100;
      print(
        '\nYLucky day! You received a bonus health boost: +100 HP'
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
      String? continueChoice;
      while (true) {
        stdout.write('\nWould you like to fight the next monster? (y/n): ');
        continueChoice = stdin.readLineSync()?.toLowerCase();

        if (continueChoice == 'y' || continueChoice == 'n') break;
        print('Invalid input. Please enter "y" or "n".');
      }

      if (continueChoice == 'n') break;
    }

    // end of the main game loop

    print('Total monsters defeated: $killedMonsters \n');

    var winORlose = player.isAlive() ? 'Win' : 'Lose';
    if (player.isAlive()) {
      print('Congratulations, ${player.name}! You defeated all monsters!');
    } else {
      print('Oh no, ${player.name}! You were defeated by the monsters.');
    }
    print('\n ጿ ኈ ቼ ዽ ጿ ኈ ቼ ዽ ጿ ኈ ቼ ዽ ጿ ኈ ቼ ዽ \n');
    print('             You $winORlose!!');
    print('\n ጿ ኈ ቼ ዽ ጿ ኈ ቼ ዽ ጿ ኈ ቼ ዽ ጿ ኈ ቼ ዽ \n');
    fileManager.savingGameResult(winORlose, player, killedMonsters);

    print('Thank you for playing!');
    print('''
♡♡ ¸.•°*”˜˜”*°•. ♡♡........
─▄████▄─▄████▄♡~✿.｡.
▐▀████████████▌♡~✿.｡.
▐█▄▓██████████▌♡~✿.｡.
─▀███████████▀♡~✿.｡.
───▀███████▀♡~✿.｡.
─────▀███▀♡~✿.｡.
───────█♡~✿.｡.
───────♡~✿.｡.:*♡♡..•°*”˜˜”*°•. ♡♡
''');
    waitForEnter();
    print('\nExiting the game...\n');
  }

  // ////////////////////////////////////////////////////////////////////////
  // battle method to handle the battle logic
  /// This method handles the battle logic between the player and a monster.
  /// It manages turns, player actions (attack, defend, use item), and monster actions.
  /// The battle continues until either the player or the monster is defeated.
  Future<void> battle() async {
    Monster? monster = getRandomMonster();
    if (monster == null) return;

    print('\n!!! 야생의 몬스터가 출현하였습니다!!!');
    await Future.delayed(Duration(milliseconds: 700));
    print('\n         ${monster.name.trim()} 의 등장!!\n');

    // Display monster's ASCII art
    print(monster.asciiArt);
    waitForEnter();

    print('\n>> ${monster.name}');
    print(monster.description.replaceAll(r'\n', '\n'));
    print('- [스킬] ${monster.skill.name}:');
    print('  ${monster.skill.description.replaceAll(r'\n', '\n')}');
    print('- [필살기] ${monster.ultimate.name}:');
    print('  ${monster.ultimate.description.replaceAll(r'\n', '\n')}\n');
    print(
      '\nHP: ${monster.hp}, Attack: ${monster.attack}, Defense: ${monster.defense}',
    );
    print(
      '══════════════════════════════•°• ⚠ •°•════════════════════════════════════\n',
    );

    while (player.isAlive() && monster.isAlive()) {
      waitForEnter();
      print(
        "\n.｡.:*･ﾟ♡★♡･*:.｡ Battle Status .｡.:*･ﾟ♡★♡･*:.｡ ｡.:*･ﾟ♡★♡･*:.｡ ｡.:*･ﾟ♡★♡･*:.｡ ｡.:*･ﾟ♡★♡",
      );
      player.showStatus();
      monster.showStatus();
      print(
        ".｡.:*･ﾟ♡★♡･*:.｡ ｡.:*･ﾟ♡★♡･*:.｡ ｡.:*･ﾟ♡★♡･*:.｡ ｡.:*･ﾟ♡★♡･*:.｡ ｡.:*･ﾟ♡★♡･*:.｡ ｡.:*･ﾟ♡★♡",
      );

      print("\n${player.name}'s turn!");
      turnCount++;
      print('Turn: $turnCount');
      if (turnCount % 3 == 0) {
        // Every 3 turns, monster increases its defense
        monster.increaseDefense(20); // Increase defense by 2
      }
      print('───✱*.｡:｡✱*.:｡✧*.｡✰*.:｡✧*.｡:｡*.｡✱ ───');

      int choice;
      bool skipMonsterTurn =
          false; // Skip monster's turn if player uses item or defends

      while (true) {
        stdout.write('Choose an action (1: Attack, 2: Defend, 3: Blueberry): ');
        String? input = stdin.readLineSync();

        if (input == null || input.trim().isEmpty) {
          print('No input! Please try again.');
          continue;
        }

        try {
          choice = int.parse(input.trim());
          if (choice < 1 || choice > 3) {
            print('Invalid input! Please enter 1, 2, or 3.');
            continue;
          }
          break; // 유효한 입력이면 반복 종료
        } catch (e) {
          print('Invalid input! Please enter a number.');
        }
      }

      switch (choice) {
        case 1:
          await player.attackMonster(monster);
          break;
        case 2:
          player.defend(monster);
          player.hp +=
              monster.attack ~/ 2; // Heal half of the monster's attack damage
          skipMonsterTurn = true;
          break;

        // Blueberry item boost
        // player can use the item to boost health
        // but can only use it once per monster
        case 3:
          if (!itemBoosted) {
            player.itemBoost(200); // Boost +100 HP and +200 Attack
            itemBoosted = true; // Mark item boost as used
            skipMonsterTurn = true; // Skip monster's turn
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

      if (skipMonsterTurn) {
        print('${monster.name}의 턴을 건너뜁니다.');
        continue; // Skip monster's turn if player defended or used item
      }

      waitForEnter();
      print('\n${monster.name}\'s turn...');

      // Randomly decide whether the monster uses a skill, ultimate, or attacks
      // 40% chance to use ultimate, 60% chance to use skill, otherwise
      double rand = Random().nextDouble();

      if (rand < 0.4 && !monster.hasUsedUltimate) {
        print('\n${monster.name}가 필살기를 사용했다!: ${monster.ultimate.name}!');
        print('${monster.ultimate.description}');
        monster.useUltimateOn(player);
        await Future.delayed(Duration(milliseconds: 500));
      } else if (rand < 0.6 && !monster.hasUsedSkill) {
        print('\n${monster.name}가 스킬을 사용했다!: ${monster.skill.name}!');
        print('${monster.skill.description}');
        monster.useSkillOn(player);
        await Future.delayed(Duration(milliseconds: 500));
      } else {
        await monster.attackCharacter(player);
      }

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
