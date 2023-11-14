import 'package:todoshka/app/modules/tasks/view/all_tasks.dart';
import 'package:todoshka/app/modules/settings/view/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:todoshka/app/modules/tasks/widgets/tasks_action.dart';
import 'package:todoshka/app/modules/todos/view/calendar_todos.dart';
import 'package:todoshka/app/modules/todos/view/all_todos.dart';
import 'package:todoshka/app/modules/todos/widgets/todos_action.dart';
import 'package:todoshka/theme/theme_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final themeController = Get.put(ThemeController());
  int tabIndex = 0;

  final pages = const [
    AllTasks(),
    AllTodos(),
    CalendarTodos(),
    SettingsPage(),
  ];

  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) => changeTabIndex(index),
        selectedIndex: tabIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Iconsax.folder_favorite),
            selectedIcon: const Icon(Iconsax.folder_favorite),
            label: 'categories'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.document_favorite),
            selectedIcon: const Icon(Iconsax.document_favorite),
            label: 'allTodos'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.calendar_tick),
            selectedIcon: const Icon(Iconsax.calendar_tick),
            label: 'calendar'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.setting4),
            selectedIcon: const Icon(Iconsax.setting4),
            label: 'settings'.tr,
          ),
        ],
      ),
      floatingActionButton: tabIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return tabIndex == 0
                        ? TasksAction(
                            text: 'create'.tr,
                            edit: false,
                          )
                        : TodosAction(
                            text: 'create'.tr,
                            edit: false,
                            category: true,
                          );
                  },
                );
              },
              child: const Icon(Iconsax.add),
            ),
    );
  }
}
