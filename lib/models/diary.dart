import 'package:isar/isar.dart';

part 'diary.g.dart';

@Collection()
class Diary {
  Id id = Isar.autoIncrement;
  late String text;
  late DateTime date;

  Diary({required this.text, required this.date});
}
