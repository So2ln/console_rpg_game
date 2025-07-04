// File: bin/console_rpg_game.dart

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
  print(
    '✿°•∘ɷ∘•°✿ ... ✿°•∘ɷ∘•°✿ ... ✿°•∘ɷ∘•°✿°•∘ɷ∘•°✿ ... ✿°•∘ɷ∘•°✿ ... ✿°•∘ɷ∘•°✿\n',
  );
  print('<Game Rules> \n');
  print('1. You will fight against random monsters.');
  print('2. Choose to attack or defend during your turn.');
  print('3. If you defeat a monster, you can continue to the next one.');
  print('4. The game ends when you are defeated or all monsters are defeated.');
  print('5. You can save your game result at the end.\n');
  print(
    '✿°•∘ɷ∘•°✿ ... ✿°•∘ɷ∘•°✿ ... ✿°•∘ɷ∘•°✿°•∘ɷ∘•°✿ ... ✿°•∘ɷ∘•°✿ ... ✿°•∘ɷ∘•°✿ \n',
  );

  waitForEnter();

  game.startGame();
}
