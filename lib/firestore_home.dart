import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FireStoreHome extends StatefulWidget {
  const FireStoreHome({super.key});

  @override
  State<FireStoreHome> createState() => _FireStoreHomeState();
}

class _FireStoreHomeState extends State<FireStoreHome> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _updateUser(DocumentSnapshot documentSnapshot) async {
    nameController.text = documentSnapshot['full_name'];
    companyController.text = documentSnapshot['company'];
    ageController.text = documentSnapshot['age'];

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // 위젯 트리 상의 위치를 알려주기 위해 빌드컨텍스트 전달
        return AlertDialog(
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '이름'),
                ),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: '회사'),
                ),
                TextField(
                  controller: ageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '나이'),
                ),
                const SizedBox(height: 20),
              ]),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text;
                final String company = companyController.text;
                final String age = ageController.text;

                await users.doc(documentSnapshot.id).update(
                    {"full_name": name, "company": company, "age": age});

                nameController.text = '';
                companyController.text = '';
                ageController.text = '';

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('업데이트'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createUser() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '이름'),
                ),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: '회사'),
                ),
                TextField(
                  controller: ageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '나이'),
                ),
                const SizedBox(height: 20),
              ]),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text;
                final String company = companyController.text;
                final String age = ageController.text;

                await users
                    .add({'full_name': name, 'company': company, 'age': age});

                nameController.text = "";
                companyController.text = "";
                ageController.text = "";

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(String userId) async {
    await users.doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clould Firestore'),
      ),
      body: StreamBuilder(
        stream: users.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 8),
                  child: ListTile(
                    leading: Text(documentSnapshot['full_name']),
                    title: Text(documentSnapshot['company']),
                    subtitle: Text(documentSnapshot['age']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(children: [
                        IconButton(
                          onPressed: () {
                            _updateUser(documentSnapshot);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteUser(documentSnapshot.id);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createUser();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
