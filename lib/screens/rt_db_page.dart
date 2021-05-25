import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RTDBPage extends StatefulWidget {
  const RTDBPage({Key key}) : super(key: key);

  @override
  _RTDBPageState createState() => _RTDBPageState();
}

class _RTDBPageState extends State<RTDBPage> {
  final dbRef = FirebaseDatabase.instance.reference();
  Stream dbData;

  final GlobalKey<FormState> _insertFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  TextEditingController _nameUpdateController = TextEditingController();
  TextEditingController _ageUpdateController = TextEditingController();

  TextEditingController _searchController = TextEditingController();

  String name;
  int age;

  String filter;
  bool isSearched = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      dbData = dbRef.onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Realtime Database Page"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(8),
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      filter = val;
                      isSearched = true;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Search Data",
                    hintText: "Enter name here",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          isSearched = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: StreamBuilder(
                stream: dbData,
                builder: (context, ss) {
                  if (ss.hasData) {
                    if (ss.data != null) {
                      DataSnapshot data = ss.data.snapshot;
                      Map res = data.value;

                      List keys = res.keys.map((key) => key).toList();
                      List values = res.values.map((val) => val).toList();

                      return (res == null)
                          ? Center(
                              child: Text("No Data Available..."),
                            )
                          : ListView.builder(
                              itemCount: res.length,
                              itemBuilder: (context, i) {
                                if (isSearched) {
                                  String name = values[i]['name'];
                                  int age = values[i]['age'];

                                  return (name.contains(RegExp(filter)))
                                      ? Card(
                                          elevation: 4,
                                          child: ExpansionTile(
                                            leading: Text("${i + 1}"),
                                            title: Text("$name - $age"),
                                            subtitle: Text("${keys[i]}"),
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  OutlinedButton.icon(
                                                    icon: Icon(
                                                        Icons.zoom_out_map),
                                                    label: Text("View"),
                                                    onPressed: () {
                                                      _showData(values[i]);
                                                    },
                                                  ),
                                                  OutlinedButton.icon(
                                                    icon: Icon(Icons.edit),
                                                    label: Text("Edit"),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      primary: Colors.green,
                                                    ),
                                                    onPressed: () {
                                                      _updateForm(
                                                          keys[i], values[i]);
                                                    },
                                                  ),
                                                  OutlinedButton.icon(
                                                    icon: Icon(Icons.delete),
                                                    label: Text("Delete"),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      primary: Colors.redAccent,
                                                    ),
                                                    onPressed: () {
                                                      _deleteData(
                                                          keys[i], values[i]);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container();
                                } else {
                                  return Card(
                                    elevation: 4,
                                    child: ExpansionTile(
                                      leading: Text("${i + 1}"),
                                      title: Text(
                                          "${values[i]['name']} - ${values[i]['age']}"),
                                      subtitle: Text("${keys[i]}"),
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            OutlinedButton.icon(
                                              icon: Icon(Icons.zoom_out_map),
                                              label: Text("View"),
                                              onPressed: () {
                                                _showData(values[i]);
                                              },
                                            ),
                                            OutlinedButton.icon(
                                              icon: Icon(Icons.edit),
                                              label: Text("Edit"),
                                              style: OutlinedButton.styleFrom(
                                                primary: Colors.green,
                                              ),
                                              onPressed: () {
                                                _updateForm(keys[i], values[i]);
                                              },
                                            ),
                                            OutlinedButton.icon(
                                              icon: Icon(Icons.delete),
                                              label: Text("Delete"),
                                              style: OutlinedButton.styleFrom(
                                                primary: Colors.redAccent,
                                              ),
                                              onPressed: () {
                                                _deleteData(keys[i], values[i]);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _insertForm,
      ),
    );
  }

  void _insertForm() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text("Insert new record"),
            ),
            content: Form(
              key: _insertFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: (val) {
                      if (val.isEmpty || val == null) {
                        return "Enter any name...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        name = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Enter your name",
                    ),
                  ),
                  TextFormField(
                    controller: _ageController,
                    validator: (val) {
                      if (val.isEmpty || val == null) {
                        return "Enter any age...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        age = int.parse(val);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Age",
                      hintText: "Enter your age",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  _nameController.clear();
                  _ageController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_insertFormKey.currentState.validate()) {
                    _insertFormKey.currentState.save();
                    _insertData();
                  }

                  _nameController.clear();
                  _ageController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Insert"),
              ),
            ],
          );
        });
  }

  void _insertData() async {
    // await dbRef.child("secondData").set({
    //   'name': name,
    //   'age': age,
    // });

    DatabaseReference ref = dbRef.push();

    await ref.set({
      'name': name,
      'age': age,
    });

    DataSnapshot res = await dbRef.child(ref.key).once();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Data Inserted...\nKey: ${ref.key} \nValue: ${res.value}"),
      ),
    );
  }

  void _showData(val) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${val['name']}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${val['name']}"),
                Text("${val['age']}"),
              ],
            ),
          );
        });
  }

  void _updateForm(key, val) {
    _nameUpdateController.text = val['name'];
    _ageUpdateController.text = val['age'].toString();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update Record"),
            content: Form(
              key: _updateFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameUpdateController,
                    validator: (val) {
                      if (val.isEmpty || val == null) {
                        return "Enter any name";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        name = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Enter your name...",
                    ),
                  ),
                  TextFormField(
                    controller: _ageUpdateController,
                    validator: (val) {
                      if (val.isEmpty || val == null) {
                        return "Enter any age";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        age = int.parse(val);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Age",
                      hintText: "Enter your age...",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  _nameUpdateController.clear();
                  _ageUpdateController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_updateFormKey.currentState.validate()) {
                    _updateFormKey.currentState.save();

                    _updateData(key, name, age);
                  }
                  _nameUpdateController.clear();
                  _ageUpdateController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Update"),
              ),
            ],
          );
        });
  }

  void _updateData(var key, String name, int age) async {
    await dbRef.child(key).update({'name': name, 'age': age});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Data of key: $key is updated..."),
      ),
    );
  }

  void _deleteData(var key, var val) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Data"),
          content: Text("Are you sure to delete this record?"),
          actions: [
            OutlinedButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
              ),
              onPressed: () async {
                await dbRef.child(key).remove();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Data of key: $key is deleted..."),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
