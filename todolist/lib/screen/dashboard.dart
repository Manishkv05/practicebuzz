import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';



class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
   List<Map<String, dynamic>> toDoItems = [];
  List<String> tododetails=[];



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadToDoItems();
  }

    Future<void> loadToDoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? toDoData = prefs.getString('toDoItems');

    if (toDoData != null) {
      setState(() {
        toDoItems = List<Map<String, dynamic>>.from(jsonDecode(toDoData));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Todo",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),),
      body:  RefreshIndicator(
        onRefresh:()async{
loadToDoItems();
        } ,
        child: ListView.builder(
          itemCount: toDoItems.length,
          itemBuilder: (context, index) {
            final item = toDoItems[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: ListTile(
                leading: Checkbox(
                  value: item['isCompleted'],
                  onChanged: (bool? value) {
                    toggleCompletion(index);
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: TextStyle(fontWeight: FontWeight.bold,
                        decoration: item['isCompleted']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                      Text(
                        item['des'],
                    
                      style: TextStyle(color: Colors.grey.shade400
                      )
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteItem(index),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new item with a simple dialog
          showDialog(
            context: context,
            builder: (context) {
                TextEditingController detailcontroller=TextEditingController();
              TextEditingController titleController = TextEditingController();
              return Container(
                height: MediaQuery.of(context).size.height*0.5,
                width:MediaQuery.of(context).size.width*0.9, 
                child: AlertDialog(
                  title: Text('New To-Do'),
                  content: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(hintText: 'Enter task title'),
                      ),
                      TextField(
                    controller: detailcontroller,
                    decoration: InputDecoration(hintText: 'Enter task details'),
                  ),
                    ],
                  ),
                  
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        addItem(titleController.text,detailcontroller.text);
                        
                        Navigator.of(context).pop();
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    
    );
  }
   Future<void> saveToDoItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('toDoItems', jsonEncode(toDoItems));
  }
   void toggleCompletion(int index) {
    setState(() {
      toDoItems[index]['isCompleted'] = !toDoItems[index]['isCompleted'];
    });
    saveToDoItems();
  }

  void deleteItem(int index) {
    setState(() {
      toDoItems.removeAt(index);
      tododetails.removeAt(index);
    });
    saveToDoItems();
  }

  void addItem(String title,String des) {
    setState(() {
      toDoItems.add({'title': title, 'des':des,'isCompleted': false});
      tododetails.add(des);
    });
    saveToDoItems();
  }
}