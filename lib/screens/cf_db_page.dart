import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CFDBPage extends StatefulWidget {
  const CFDBPage({Key key}) : super(key: key);

  @override
  _CFDBPageState createState() => _CFDBPageState();
}

class _CFDBPageState extends State<CFDBPage> {
  Stream<QuerySnapshot> collectionStream;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _insertFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  TextEditingController _nameUpdateController = TextEditingController();
  TextEditingController _ageUpdateController = TextEditingController();

  TextEditingController _searchController = TextEditingController();

  String name;
  int age;

  @override
  void initState() {
    super.initState();
    setState(() {
      collectionStream = firestore.collection('users').snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cloud Firestore Page"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (val) async {
                    setState(() {
                      collectionStream = firestore
                          .collection('users')
                          .where('name', isEqualTo: val)
                          .snapshots();
                    });
                    if (val.isEmpty) {
                      setState(() {
                        collectionStream =
                            firestore.collection("users").snapshots();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search by name",
                    suffixIcon: InkWell(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          collectionStream =
                              firestore.collection("users").snapshots();
                        });
                      },
                      child: Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: StreamBuilder<QuerySnapshot>(
                stream: collectionStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> ss) {
                  if (ss.hasError) {
                    return Center(
                      child: Text("Something went wrong.\nError: ${ss.error}"),
                    );
                  }
                  if (ss.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<QueryDocumentSnapshot> data = ss.data.docs;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      return Card(
                        child: Slidable(
                          actionPane: SlidableScrollActionPane(),
                          secondaryActions: [
                            IconSlideAction(
                              icon: Icons.edit,
                              color: Colors.blue,
                              caption: "EDIT",
                              onTap: () {
                                _updateData(data[i].id, data[i].data());
                              },
                            ),
                            IconSlideAction(
                              icon: Icons.delete,
                              color: Colors.red,
                              caption: "DELETE",
                              onTap: () {
                                _deleteData(data[i].id);
                              },
                            ),
                          ],
                          child: ListTile(
                            leading: Text("${i + 1}"),
                            title: Text("${data[i]['name']}"),
                            subtitle: Text("${data[i].id}"),
                            trailing: Text("Age: ${data[i]['age']}"),
                          ),
                        ),
                      );
                    },
                  );
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
    DocumentReference<Map<String, dynamic>> res =
        await firestore.collection("users").add({
      'name': name,
      'age': age,
    });

    DocumentSnapshot<Map<String, dynamic>> ds = await res.get();

    Map data = ds.data();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Record Inserted.\nID: ${res.id}\nData: $data"),
      ),
    );
  }

  void _deleteData(String id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text("Delete Record"),
          ),
          content: Text("Are you sure to delete this record?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
                onPrimary: Colors.white,
              ),
              onPressed: () async {
                await firestore.collection('users').doc(id).delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Record deleted.\nID: $id"),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _updateData(String id, Map data) async {
    _nameUpdateController.text = data['name'];
    _ageUpdateController.text = data['age'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text("Update Record"),
          ),
          content: Form(
            key: _updateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameUpdateController,
                  validator: (val) {
                    if (val.isEmpty || val == null) {
                      return "Enter any name here";
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
                    hintText: "Enter your name here",
                  ),
                ),
                TextFormField(
                  controller: _ageUpdateController,
                  validator: (val) {
                    if (val.isEmpty || val == null) {
                      return "Enter any age here";
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
                    hintText: "Enter your age here",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () async {
                if (_updateFormKey.currentState.validate()) {
                  _updateFormKey.currentState.save();

                  Map<String, dynamic> newData = {
                    'name': name,
                    'age': age,
                  };

                  await firestore.collection('users').doc(id).update(newData);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Record updated.\nID: $id"),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
