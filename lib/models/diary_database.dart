import 'package:bukuharian/models/diary.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class DiaryDatabase extends ChangeNotifier {
  static late Isar isar;

  // Inisialisasi database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [DiarySchema],
      directory: dir.path,
    );
  }

  // List diary
  final List<Diary> currentDiary = [];

  // Create
  Future<void> addDiary(String textFromUser, DateTime date) async {
    // Buat objek diary baru
    final newDiary = Diary(text: textFromUser, date: date);

    // Simpan ke db
    await isar.writeTxn(() => isar.diarys.put(newDiary));

    // Fetch dari db
    fetchDiary();
  }

  // Read
  Future<void> fetchDiary() async {
    List<Diary> fetchedDiary = await isar.diarys.where().findAll();
    currentDiary.clear();
    currentDiary.addAll(fetchedDiary);
    notifyListeners();
  }

  // Update
  Future<void> updateDiary(int id, String newText, DateTime newDate) async {
    final dataLama = await isar.diarys.get(id);
    if (dataLama != null) {
      dataLama.text = newText;
      dataLama.date = newDate;
      await isar.writeTxn(() => isar.diarys.put(dataLama));
      await fetchDiary();
    }
  }

  // Delete
  Future<void> deleteDiary(int id) async {
    await isar.writeTxn(() => isar.diarys.delete(id));
    await fetchDiary();
  }
}
