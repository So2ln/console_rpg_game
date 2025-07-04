import 'dart:io';
import 'dart:convert';

String getCharacterName() {
  while (true) {
    stdout.write('\n What should I call you? : ');
    String? inputName = stdin.readLineSync(
      encoding: Encoding.getByName('utf-8')!,
    );

    if (inputName == null || inputName.trim().isEmpty) {
      print('No input detected! Please enter a name.');
      continue;
    }

    if (!RegExp(r'^[a-zA-Z가-힣 ]+$').hasMatch(inputName)) {
      print('Please use only Korean or English letters!');
      continue;
    }

    inputName = inputName.trim();
    print('$inputName!! What a great name! Welcome, $inputName!\n');

    return inputName;
  }
}

void waitForEnter() {
  // Wait for the user to press Enter
  //stdout.write('(>> press Enter to continue..)');
  stdout.write('\n >> 𝓹𝓻𝓮𝓼𝓼 𝓔𝓷𝓽𝓮𝓻 𝓽𝓸 𝓬𝓸𝓷𝓽𝓲𝓷𝓾𝓮.. ');
  stdin.readLineSync();
}
