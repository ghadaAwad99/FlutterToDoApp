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

  List<Map> newTasksList = [];
  List<Map> doneTasksList = [];
  List<Map> archivedTasksList = [];
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
      getTasksFromDatabase(database);
    }).then((value) {
      db = value;
      emit(AppCreateDatabaseState());
    });
  }

  void insertToDatabase(String title, String date, String time) async {
    await db.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO Tasks(title, date, time, status) VALUES("$title", "$date", "$time", "${Constants.NEW}")')
          .then((value) {
        print("$value inserted");
        emit(AppInsertToDatabaseState());
        getTasksFromDatabase(db);
      }).catchError((error) {
        print(error.toString());
      });
    });
  }

  void getTasksFromDatabase(db) async {
    newTasksList = [];
    doneTasksList = [];
    archivedTasksList = [];
    emit(AppIsLoadingState());
    await db.rawQuery('SELECT * FROM Tasks').then((value) {
      print("tasksList $value");
      value.forEach((task) {
        if (task['status'] == Constants.NEW) {
          newTasksList.add(task);
        } else if (task['status'] == Constants.DONE) {
          doneTasksList.add(task);
        } else if (task['status'] == Constants.ARCHIVED) {
          archivedTasksList.add(task);
        }
      });
      emit(AppGetFromDatabaseState());
    });
  }

  void updateDatabase({required String status, required int id}) async {
    await db.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      emit(AppUpdateDatabaseState());
      getTasksFromDatabase(db);
    });
  }

  void deleteTask(taskId) async {
    await db
        .rawDelete('DELETE FROM Tasks WHERE id = ?', [taskId]).then((value) {
      emit(AppDeleteDatabaseState());
      getTasksFromDatabase(db);
    });
  }
}
