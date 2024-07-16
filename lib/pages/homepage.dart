import 'package:bukuharian/models/diary.dart';
import 'package:bukuharian/models/diary_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final textController = TextEditingController();
  final selecDate = TextEditingController();
  final selecDate1 = TextEditingController();

  @override
  void initState() {
    super.initState();

    //ambil data yang sudah ada
    readDiary();
  }

  //buat diary
  void createDiary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Diary Baru"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: textController,
                minLines: 1,
                maxLines: 100,
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selecDate1.text =
                          DateFormat('dd MMMM yyyy').format(pickedDate);
                      selecDate.text = pickedDate.toString();
                    });
                  }
                },
                child: TextField(
                  enabled: false,
                  controller: selecDate1,
                  minLines: 1,
                  maxLines: 100,
                ),
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              //menambahkan ke db
              context.read<DiaryDatabase>().addDiary(
                  textController.text, DateTime.parse(selecDate.text));

              //membersihkan controller
              textController.clear();

              //pop dialog box
              Navigator.pop(context);
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  //baca diary
  void readDiary() {
    context.read<DiaryDatabase>().fetchDiary();
  }

  //perbarui diary
  void updateDiary(Diary diary) {
    //munculkan text diary yang ada sekarang
    textController.text = diary.text;
    selecDate1.text = DateFormat('dd MMMM yyyy').format(diary.date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Perbarui Diary"),
        content: SingleChildScrollView(
            child: Column(
          children: [
            TextField(controller: textController),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selecDate1.text =
                        DateFormat('dd MMMM yyyy').format(pickedDate);
                    selecDate.text = pickedDate.toString();
                  });
                }
              },
              child: TextField(
                enabled: false,
                controller: selecDate1,
                minLines: 1,
                maxLines: 100,
              ),
            ),
          ],
        )),
        actions: [
          //munculkan tombol update
          MaterialButton(
            onPressed: () {
              //perbarui data di db
              context.read<DiaryDatabase>().updateDiary(diary.id,
                  textController.text, DateTime.parse(selecDate.text));
              //clear controller
              textController.clear();
              //pop dialog box
              Navigator.pop(context);
            },
            child: const Text("Perbarui"),
          ),
        ],
      ),
    );
  }

  //hapus diary
  void deleteDiary(int id) {
    context.read<DiaryDatabase>().deleteDiary(id);
  }

  @override
  Widget build(BuildContext context) {
    // diary database
    final diaryDatabase = context.watch<DiaryDatabase>();

    //current diary
    List<Diary> currentDiary = diaryDatabase.currentDiary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("demo"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createDiary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          //heading
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Buku Harian",
            ),
          ),

          //daftar diary
          Expanded(
            child: ListView.builder(
              itemCount: currentDiary.length,
              itemBuilder: (context, index) {
                //mengambil data individual
                final diary = currentDiary[index];

                //list tile UI yang bisa di-slide
                return Slidable(
                  key: ValueKey(diary.id),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => updateDiary(diary),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) => deleteDiary(diary.id),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(diary.text),
                    subtitle:
                        Text(DateFormat('dd MMMM yyyy').format(diary.date)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
