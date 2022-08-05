import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../../modules/archived_tasks/archived_tasks.dart';
import '../../modules/done_tasks/done_tasks.dart';
import '../../modules/new_tasks/new_tasks.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit getCubitInstance(context) => BlocProvider.of(context);

  late Database db;
  List<Map> tasksList = [];
  bool isBottomSheetShown = false;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  int currentIndex = 0;

  void changeBottomNavIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavItemState());
  }

  void changeBottomSheetState(bool isBottomSheetShown) {
    this.isBottomSheetShown = isBottomSheetShown;
    emit(AppChangeBottomSheetState());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {
        print('table created');
      }).catchError((error) {
        print('error on creating table ${error.toString()}');
      });
    }, onOpen: (database) {
      print('database opened');
      getTasksFromDatabase(database).then((value) {
        tasksList = value;
        print(tasksList);
        emit(AppGetFromDatabaseState());
      });
    }).then((value) {
      db = value;
      emit(AppCreateDatabaseState());
    });
  }

  void insertToDatabase(String title, String date, String time) async {
    await db.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO Tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        print("$value inserted");
        emit(AppInsertToDatabaseState());
        getTasksFromDatabase(db).then((value) {
          tasksList = value;
          print(tasksList);
          emit(AppGetFromDatabaseState());
        });
      }).catchError((error) {
        print(error.toString());
      });
    });
  }

  Future<List<Map>> getTasksFromDatabase(db) async {
    emit(AppIsLoadingState());
    return await db.rawQuery('SELECT * FROM Tasks');
  }
}
