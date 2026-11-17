import 'package:flutter/material.dart';
import 'AppDatabase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  late AppDatabase db;
  List<Contact> contactList = [];
  Contact? selectedItem;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    _loadContacts();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final contacts = await db.getAllContacts().get();
    setState(() {
      contactList = contacts;
    });
  }

  void _addContact() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    db.saveContact(name, phone).then((generatedId) {
      nameController.clear();
      phoneController.clear();
      _loadContacts();
    });
  }

  void _deleteContact(int id) {
    db.deleteContact(id).then((_) {
      setState(() {
        if (selectedItem?.id == id) {
          selectedItem = null;
        }
      });
      _loadContacts();
    });
  }

  Widget listPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
              ),
              ElevatedButton(
                onPressed: _addContact,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: contactList.length,
            itemBuilder: (context, index) {
              final item = contactList[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.phone),
                selected: selectedItem?.id == item.id,
                onTap: () {
                  setState(() {
                    selectedItem = item;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget detailsPage() {
    if (selectedItem == null) {
      return const Center(
        child: Text('Select an item from the list to view details'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Name: ${selectedItem!.name}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Phone: ${selectedItem!.phone}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            'Database ID: ${selectedItem!.id}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _deleteContact(selectedItem!.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedItem = null;
                  });
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget reactiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: listPage(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: detailsPage(),
          ),
        ],
      );
    } else {
      if (selectedItem == null) {
        return listPage();
      } else {
        return detailsPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 8 - Responsive Contacts')),
      body: reactiveLayout(),
    );
  }
}
