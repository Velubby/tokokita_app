import 'dart:math';

class IDGenerator {
  static String generateID() {
    final random = Random();
    final randomDigits = List.generate(8, (_) => random.nextInt(10)).join();
    return 'BRG-$randomDigits';
  }
}
