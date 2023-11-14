import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:todoshka/app/controller/controller.dart';
import 'package:todoshka/app/modules/tasks/widgets/task_list.dart';
import 'package:todoshka/app/modules/tasks/widgets/statistics.dart';
import 'package:todoshka/app/widgets/text_form.dart';

class AllTasks extends StatefulWidget {
  const AllTasks({super.key});

  @override
  State<AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  TextEditingController searchTasks = TextEditingController();
  String filter = '';
  bool showArchived = false;

  applyFilter(String value) async {
    filter = value.toLowerCase();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var createdTodos = todoController.createdAllTodos();
    var completedTodos = todoController.completedAllTodos();
    var precent = (completedTodos / createdTodos * 100).toStringAsFixed(0);

    return WillPopScope(
      onWillPop: () async {
        if (todoController.isMultiSelectionTask.isTrue) {
          todoController.selectedTask.clear();
          todoController.isMultiSelectionTask.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: todoController.isMultiSelectionTask.isTrue
              ? IconButton(
                  onPressed: () {
                    todoController.selectedTask.clear();
                    todoController.isMultiSelectionTask.value = false;
                  },
                  icon: const Icon(
                    Iconsax.close_square,
                    size: 20,
                  ),
                )
              : null,
          title: Text(
            'categories'.tr,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Visibility(
              visible: todoController.selectedTask.isNotEmpty,
              child: IconButton(
                icon: const Icon(
                  Iconsax.trush_square,
                  size: 20,
                ),
                onPressed: () async {
                  await showAdaptiveDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog.adaptive(
                        title: Text(
                          'deleteCategory'.tr,
                          style: context.textTheme.titleLarge,
                        ),
                        content: Text(
                          'deleteCategoryQuery'.tr,
                          style: context.textTheme.titleMedium,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Get.back(),
                              child: Text('cancel'.tr,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                          color: const Color.fromARGB(255, 240, 167, 189)))),
                          TextButton(
                              onPressed: () {
                                todoController.deleteTask(
                                    todoController.selectedTask);
                                todoController.selectedTask.clear();
                                todoController.isMultiSelectionTask.value =
                                    false;
                                Get.back();
                              },
                              child: Text('delete'.tr,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(color: Colors.red))),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(
                showArchived ? Iconsax.archive_1 : Iconsax.refresh_left_square,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  showArchived = !showArchived;
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            MyTextForm(
              labelText: 'searchCategory'.tr,
              type: TextInputType.text,
              icon: const Icon(
                Iconsax.search_favorite,
                size: 20,
              ),
              controller: searchTasks,
              margin: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              onChanged: applyFilter,
              iconButton: searchTasks.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchTasks.clear();
                        applyFilter('');
                      },
                      icon: const Icon(
                        Iconsax.close_circle,
                        color: Colors.grey,
                        size: 20,
                      ),
                    )
                  : null,
            ),
            Statistics(
              createdTodos: createdTodos,
              completedTodos: completedTodos,
              precent: precent,
            ),
            Expanded(
              child: TasksList(
                archived: showArchived,
                searhTask: filter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
