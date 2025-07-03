# Dart Console RPG Game

A console-based turn-based RPG game written in **Dart**, featuring file I/O, randomness, OOP design, and gameplay interactivity.

---

## 📁 Project Structure

```
project_root/
├── bin/
│   └── console_rpg_game.dart     # Entry point (main)
├── lib/
│   ├── file_manager.dart         # Handles file loading and saving (FileManager class)
│   ├── game.dart                 # Game loop and battle flow (Game class)
│   ├── utils.dart                # Helper functions (e.g., getCharacterName)
│   └── models/
│       ├── character.dart        # Player character class (Character)
│       ├── monster.dart          # Enemy monster class (Monster)
│       └── game_object.dart      # Abstract superclass for shared properties (GameObject)
├── assets/
│   ├── characters.txt            # Initial character stats (HP, ATK, DEF)
│   └── monsters.txt              # List of monsters and their stats
└── result.txt                    # Game results saved by the player
```

---

## 🎮 How to Play

1. Run the entry file:

```bash
dart run bin/console_rpg_game.dart
```

2. Game loads character and monster stats from files.
3. Player inputs their name (validated to contain only Korean or English letters).
4. Turn-based battles begin against random monsters.
5. Player chooses to:

   * Attack (1)
   * Defend (2)
   * Use Item (3, once per battle)
6. After each battle:

   * If HP > 0, player can choose to continue or end.
   * If all monsters are defeated → Victory.
7. At the end, player can choose to save results to `result.txt`.


---

## 💡 Sample Gameplay Output

```
🚀 Welcome to the Dart Console RPG Game!

Loading game data...
> Character loaded with stats: HP: 50, ATK: 10, DEF: 5
> Bonus HP granted! New HP: 60

What should I call you? : SirCode

🎯 A wild Spiderman appeared!
Spiderman (HP: 30, ATK: 15)
SirCode (HP: 60, ATK: 10, DEF: 5)

Your turn! What will you do?
1: Attack  2: Defend  3: Use Item
> 1

🗡️ You attacked Spiderman!
Spiderman took 8 damage! Remaining HP: 22

Spiderman attacks!
You received 10 damage. Your HP: 50
...
📣 Spiderman was defeated!
Would you like to fight the next monster? (y/n)
> y

🎯 A wild Batman appeared!
...
🏆 You defeated all monsters!
Would you like to save the result? (y/n)
> y
✅ Game result saved in result.txt
```

---

## 🧠 Class Responsibility Overview

### `GameObject` (abstract class)

* Shared by `Character` and `Monster`
* Fields:

  * `String name`
  * `int hp`
  * `int attack`
  * `int defense`
* Methods:

  * `showStatus()`
  * `attacking(GameObject target)`
  * `defending(int damage)`
  * `bool isAlive()`

### `Character extends GameObject`

* Behavior:

  * `attackMonster(Monster)`
  * `defend()` (reflects damage reduction logic)

* Extra behavior:  
  * `itemBoost()` (optional item use)

### `Monster extends GameObject`

* Behavior:

  * `attackCharacter(Character)`

* Extra behavior:   
  * `turn-based defense buff`: every 3rd turn, defense increases by 2

### `FileManager`

* Methods:

  * `loadGameData()` → Loads characters and monsters from files
  * `savingGameResult(String result, Character player, int killedMonsters)` → Saves result to `result.txt`

### `Game`

* Core gameplay controller
* Methods:

  * `startGame()`
  * `battle()`
  * `getRandomMonster()`

* Tracks:

  * `Character player`
  * `List<Monster> allMonsters`
  * `int killedMonsters`

### `utils.dart`

* Helper function for name input:

  * `getCharacterName()` with regex validation

---

## ✨ Features Implemented

### 필수 기능 (Required)

* 파일로부터 캐릭터/몬스터 정보 불러오기
* 이름 유효성 검사
* 몬스터 랜덤 등장
* 공격/방어 로직 구현
* 공통 추상 클래스 사용
* 전투 결과 저장 기능

### 도전 기능 (Challenge Features)

* 30% 확률로 체력 보너스 부여
* 전투 중 아이템 사용 기능 (1회 한정)
* 3턴마다 몬스터 방어력 증가

* 추가 기능
    * 사용자 친화적 인터페이스 (엔터 대기, print 딜레이)
    * 몬스터 공격 시 스킬명 출력
    * 아스키아트 구현
    * 남은 몬스터 보기 기능

---

## ✍️ Author

Developed by \[Your Name].
For educational purposes in Dart OOP & CLI programming.

---

## 📌 Notes

* 모든 입력은 유효성 검사를 포함합니다.
* 게임 로직은 순차적이며, 상태는 전투 간 유지됩니다.
* 추후 몬스터 스킬 추가, 캐릭터 성장 시스템 등 확장 가능합니다.
