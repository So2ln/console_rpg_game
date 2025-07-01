import 'dart:io'; // Library to receive user input from the console
import 'dart:async';
import 'dart:math';

void main() async {}

/// //////////////////////////////////////////////////////////
/// RPG Game class definition
///
class Game {
  Character player;
  List<Monster> allMonsters;
  int killedMonsters;

  Game(this.player, this.allMonsters, this.killedMonsters);

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
      final characterFile = File('characters.txt');
      final lines = await characterFile.readAsLines();
      if (lines.isEmpty) throw FormatException('Please add the character file!');

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
        int hp = 0;
    int attack = 0;
    int defense = 0;

    try {
    final monsterFile = File('monsters.txt');
    if (await monsterFile.exists()) {
      final lines = await monsterFile.readAsLines();

      var randomRow = Random();

      for (var line in lines) {
        final info = line.split(',');

        var currName = info[0];
        Monster $currName = Monster(
          info[0],
          int.parse(info[1]),
          int.parse(info[2]),
        );
      }
    } else {
      print('Please add the character file!');
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

class ShoppingMall {
  List<Product> allProducts; // List of all products
  int totalPrice; // Total amount in the cart
  List<String> totalList; // Stores the names of products added to the cart
  List<String> totalAmount; // Stores the quantity of each product added

  ShoppingMall(
    this.allProducts,
    this.totalPrice,
    this.totalList,
    this.totalAmount,
  ); // Constructor

  /// Display all available products
  void showProducts() {
    for (var idx = 0; idx < allProducts.length; idx++) {
      var currItem = allProducts[idx];

      /// for (var currItem in allProducts) {
      currItem.info(); // Print info for each product (e.g. 셔츠 / 45000원)
    }
  }

  /// Add a product to the shopping cart
  void addToCart() {
    stdout.write('상품명을 입력하세요: ');
    String? inputName = stdin
        .readLineSync()
        .toString(); // Get product name input

    stdout.write('수량을 입력하세요: ');
    String? inputAmount = stdin.readLineSync().toString(); // Get quantity input

    try {
      String? currName = inputName;
      Product? foundProduct;

      int amount = int.parse(inputAmount); // Convert quantity to integer

      // If the product name is invalid
      if (!KorToEng.containsKey(inputName)) {
        print('입력값이 올바르지 않아요!');
      }
      // if the quantity if 0 or less
      else if (amount <= 0) {
        print('0개보다 많은 개수의 상품만 담을 수 있어요!');
      } else {
        // Search for the product in the product list
        for (var item in allProducts) {
          if (item.name == currName) {
            foundProduct = item;
            break;
          }
        }

        // If product was found
        if (foundProduct == null) {
          print('입력값이 올바르지 않아요!');
        } else {
          // Add to the total price in the cart
          totalPrice += foundProduct.price * amount;

          // Save product name and quantity into shopping list
          totalList.add(foundProduct.name); // ex. 셔츠
          totalAmount.add(amount.toString()); // ex. '2'
          print('장바구니에 상품이 담겼어요!');
        }
      }
    } catch (e) {
      // If the quantity input is not a valid number
      print('입력값이 올바르지 않아요!');
    }
  }
}

/// Main function - entry point of the program

void main() {
  // Create product instances
  Product shirt = Product('셔츠', 45000);
  Product dress = Product('원피스', 30000);
  Product tShirt = Product('반팔티', 35000);
  Product short = Product('반바지', 38000);
  Product socks = Product('양말', 5000);

  /// //////////////////////////////////////

  // Create a shopping mall instance w/ the product list
  ShoppingMall mall = ShoppingMall(
    [shirt, dress, tShirt, short, socks],
    0,
    [],
    [],
  );

  // Infinite loop - keeps running until the user chooses to quit
  while (true) {
    // Display the menu
    print(
      '\n======================================================================================================',
    );
    print(
      '[1] 상품 목록 보기 / [2] 장바구니에 담기 / [3] 장바구니 보기 / [4] 프로그램 종료 / [6] 장바구니 초기화',
    );
    print(
      '======================================================================================================\n',
    );

    stdout.write('메뉴를 입력하세요: ');

    try {
      // Read user input as integer
      int? menu = int.parse(stdin.readLineSync().toString());

      switch (menu) {
        case 1:
          mall.showProducts(); // Show all products
          break;

        case 2:
          mall.addToCart(); // Add product to cart
          break;

        case 3:

          /// Show total cart price and the full shopping list

          if (mall.totalPrice == 0) {
            print('이미 장바구니가 비어있습니다.');
          } else {
            print('장바구니에 ${mall.totalPrice} 원 어치를 담으셨네요!');
            print('\n <쇼핑 리스트>');

            // Print each product and its quantity
            for (var i = 0; i < mall.totalList.length; i++) {
              print('\n - ${mall.totalList[i]} * ${mall.totalAmount[i]} 개');
            }
          }
          break;

        case 4:
          // Ask for confirmation before exiting
          stdout.write('정말 종료하시겠습니까? 종료하시려면 [5]를 눌러주세요.');

          try {
            int? menuQuit = int.parse(stdin.readLineSync().toString());

            if (menuQuit == 5) {
              print('이용해주셔서 감사합니다~ 안녕히 가세요!');
              return; // Exit the console
            } else {
              print('종료하지 않습니다.');
            }
          } catch (e) {
            // If confirmation input is not a valid number
            print('입력값이 올바르지 않아요!');
          }
          break;

        case 6:
          // Reset the cart
          if (mall.totalPrice == 0) {
            print('이미 장바구니가 비어있습니다.');
          } else {
            print('장바구니를 초기화합니다.');
            mall.totalPrice = 0; // clear total prices
            mall.totalList.clear(); // Also clear product names
            mall.totalAmount.clear(); // And quantities
          }
          break;

        default:
          // When the user enters a number that is not in the menu
          print('지원하지 않는 기능입니다! 다시 시도해주세요..');
      }
    } catch (e) {
      // When the input cannot be parsed to an integer
      print('예상치 못한 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }
}
