import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:todoshka/app/data/schema.dart';
import 'package:todoshka/app/controller/controller.dart';
import 'package:todoshka/app/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:todoshka/main.dart';

class TodosAction extends StatefulWidget {
  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    required this.category,
    this.task,
    this.todo,
  });

  final String text;
  final Tasks? task;
  final Todos? todo;
  final bool edit;
  final bool category;

  @override
  State<TodosAction> createState() => _TodosActionState();
}

class _TodosActionState extends State<TodosAction> {
  final formKey = GlobalKey<FormState>();
  final todoController = Get.put(TodoController());
  Tasks? selectedTask;
  List<Tasks>? task;
  final FocusNode focusNode = FocusNode();
  final textController = TextEditingController();
  TextEditingController titleEdit = TextEditingController();
  TextEditingController descEdit = TextEditingController();
  TextEditingController timeEdit = TextEditingController();

  @override
  void initState() {
    if (widget.edit) {
      selectedTask = widget.todo!.task.value;
      textController.text = widget.todo!.task.value!.title;
      titleEdit = TextEditingController(text: widget.todo!.name);
      descEdit = TextEditingController(text: widget.todo!.description);
      timeEdit = TextEditingController(
        text: widget.todo!.todoCompletedTime != null
            ? DateFormat.yMMMEd(locale.languageCode)
                .add_Hm()
                .format(widget.todo!.todoCompletedTime!)
            : '',
      );
    }
    super.initState();
  }

  Future<List<Tasks>> getTodosAll(String pattern) async {
    return isar.tasks.filter().archiveEqualTo(false).findAllSync();
  }

  textTrim(value) {
    value.text = value.text.trim();
    while (value.text.contains('  ')) {
      value.text = value.text.replaceAll('  ', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        titleEdit.clear();
                        descEdit.clear();
                        timeEdit.clear();
                        textController.clear();
                        Get.back();
                      },
                      icon: const Icon(
                        Iconsax.close_square,
                        size: 20,
                      ),
                    ),
                    Text(
                      widget.text,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          textTrim(titleEdit);
                          textTrim(descEdit);
                          widget.edit
                              ? todoController.updateTodo(
                                  widget.todo!,
                                  selectedTask!,
                                  titleEdit.text,
                                  descEdit.text,
                                  timeEdit.text,
                                )
                              : widget.category
                                  ? todoController.addTodo(
                                      selectedTask!,
                                      titleEdit.text,
                                      descEdit.text,
                                      timeEdit.text,
                                    )
                                  : todoController.addTodo(
                                      widget.task!,
                                      titleEdit.text,
                                      descEdit.text,
                                      timeEdit.text,
                                    );
                          textController.clear();
                          titleEdit.clear();
                          descEdit.clear();
                          timeEdit.clear();
                          Get.back();
                        }
                      },
                      icon: const Icon(
                        Iconsax.tick_square,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              widget.category
                  ? RawAutocomplete<Tasks>(
                      focusNode: focusNode,
                      textEditingController: textController,
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        return MyTextForm(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          onChanged: (value) => setState(() {}),
                          controller: textController,
                          focusNode: focusNode,
                          labelText: 'selectCategory'.tr,
                          type: TextInputType.text,
                          icon: const Icon(Iconsax.folder_favorite),
                          iconButton: textController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    textController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'selectCategory'.tr;
                            }
                            return null;
                          },
                        );
                      },
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return getTodosAll(textEditingValue.text);
                      },
                      onSelected: (Tasks selection) {
                        textController.text = selection.title;
                        selectedTask = selection;
                        focusNode.unfocus();
                      },
                      displayStringForOption: (Tasks option) => option.title,
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<Tasks> onSelected,
                          Iterable<Tasks> options) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Material(
                              borderRadius: BorderRadius.circular(20),
                              elevation: 4.0,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Tasks tasks = options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(tasks),
                                    child: ListTile(
                                      title: Text(
                                        tasks.title,
                                        style: context.textTheme.labelLarge,
                                      ),
                                      trailing: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Color(tasks.taskColor),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                controller: titleEdit,
                labelText: 'name'.tr,
                type: TextInputType.multiline,
                icon: const Icon(Iconsax.heart_edit),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validateName'.tr;
                  }
                  return null;
                },
                maxLine: null,
              ),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                controller: descEdit,
                labelText: 'description'.tr,
                type: TextInputType.multiline,
                icon: const Icon(Iconsax.note5),
                maxLine: null,
              ),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                onChanged: (value) => setState(() {}),
                readOnly: true,
                controller: timeEdit,
                labelText: 'timeComlete'.tr,
                type: TextInputType.datetime,
                icon: const Icon(Iconsax.clock),
                iconButton: timeEdit.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                        onPressed: () {
                          timeEdit.clear();
                          setState(() {});
                        },
                      )
                    : null,
                onTap: () {
                  BottomPicker.dateTime(
                    titlePadding: const EdgeInsets.only(top: 10),
                    title: 'time'.tr,
                    description: 'timeDesc'.tr,
                    titleStyle: context.textTheme.titleMedium!,
                    descriptionStyle: context.textTheme.labelLarge!
                        .copyWith(color: Colors.grey),
                    pickerTextStyle:
                        context.textTheme.labelMedium!.copyWith(fontSize: 15),
                    closeIconColor: Colors.red,
                    backgroundColor: context.theme.primaryColor,
                    onSubmit: (date) {
                      String formattedDate =
                          DateFormat.yMMMEd(locale.languageCode)
                              .add_Hm()
                              .format(date);
                      timeEdit.text = formattedDate;
                      setState(() {});
                    },
                    bottomPickerTheme: BottomPickerTheme.blue,
                    minDateTime: DateTime.now(),
                    maxDateTime: DateTime.now().add(const Duration(days: 1000)),
                    initialDateTime: DateTime.now(),
                    use24hFormat: true,
                    dateOrder: DatePickerDateOrder.dmy,
                  ).show(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
