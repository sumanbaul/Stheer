import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';

class HabitListerWidget extends StatefulWidget {
  HabitListerWidget({Key? key}) : super(key: key);

  @override
  State<HabitListerWidget> createState() => _HabitListerWidgetState();
}

class _HabitListerWidgetState extends State<HabitListerWidget> {
  final List<Color> _cardColors = [
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 233, 233, 233)
  ];

  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await DatabaseHelper.instance.getHabits();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // _refreshJournals(); // Loading the diary when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
          // height: 600,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              boxShadow: [
                //color: Colors.white, //background color of box
                BoxShadow(
                  color: Color.fromARGB(255, 190, 190, 190),
                  blurRadius: 25.0, // soften the shadow
                  spreadRadius: 3.0, //extend the shadow
                  offset: Offset(
                    5.0, // Move to right 10  horizontally
                    5.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
              color: Color(0xFFEFEEEE)),
          child: ListView.builder(
            itemBuilder: _buildHabitItem,
            itemCount: 20,
            physics: BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          )),
    );
  }

  Widget _buildHabitItem(BuildContext context, int index) {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 115,
        width: MediaQuery.of(context).size.width * 0.9,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        // padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: Offset(-6.0, -6.0),
              blurRadius: 16.0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(6.0, 6.0),
              blurRadius: 16.0,
            ),
          ],
          color: Color(0xFFEFEEEE),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: 7,
              color: Colors.blueGrey,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // CircleAvatar(
                      //   //radius: 25.0,
                      //   //backgroundImage: _nc[index].appIcon,
                      //   child: item.appIcon,
                      //   // child: ClipRRect(
                      //   //   child: _nc[index].appIcon,
                      //   //   borderRadius: BorderRadius.circular(100.0),
                      //   // ),
                      //   backgroundColor: Colors.white10,
                      // ),
                      SizedBox(
                        width: 8,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: new Text(
                              "Habit 1",
                              //overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 3.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.black45,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {},
                      child: Text('🔥 Mark Complete'),
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red),
                        )),
                      )),
                  Expanded(
                    flex: 1,
                    child: new SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      dragStartBehavior: DragStartBehavior.start,
                      child: Container(
                        padding: const EdgeInsets.only(top: 10.0),
                        width: MediaQuery.of(context).size.width * 0.87,
                        //height: 45.0,
                        child: Text(
                          "No text to display",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      // Clear the text fields
                      _titleController.text = '';
                      _descriptionController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  // Insert a new journal to the database
  Future<void> _addItem() async {
    // await DatabaseHelper.instance.createHabit(
    //     _titleController.text, _descriptionController.text);
    // _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await DatabaseHelper.instance.updateHabitItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteHabitItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }
}
