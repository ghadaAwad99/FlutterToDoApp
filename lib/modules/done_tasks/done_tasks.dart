import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/components/components.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class DoneTasksScreen extends StatelessWidget {
  const DoneTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var tasksList = AppCubit.getCubitInstance(context).doneTasksList;
        return ConditionalBuilder(
          condition: tasksList.isNotEmpty,
          builder: (context) => ListView.separated(
            itemBuilder: (context, index) =>
                taskItem(tasksList[index], context),
            separatorBuilder: (context, index) => Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey[300],
            ),
            itemCount: tasksList.length,
          ),
          fallback: (context) => const Center(
              child: Text(
            'No Done Tasks',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 32,
            ),
          )),
        );
      },
    );
  }
}
