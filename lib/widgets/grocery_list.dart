import 'dart:convert';

import 'package:flutter/Material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key , required this.username});

  final String username;

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final url = Uri.https(
        'flutter-shopping-list-ap-fc113-default-rtdb.firebaseio.com',
        'shopping-list.json');

    final response = await http.get(url);
    print(response.statusCode);
    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data , please try again later!';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_error!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
        backgroundColor: Colors.red,
        duration: const Duration(minutes: 3),
      ));
    }
    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
        if (_username == item.value['username']) {
          loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
          username: _username,
        ));
        }
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.push<GroceryItem>(
        context, MaterialPageRoute(builder: (ctx) =>  NewItem(username: _username,)));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'flutter-shopping-list-ap-fc113-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
        _error = 'Failed to remove item , please try again later!';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_error!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'Add some groceries!',
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Colors.blueGrey, fontWeight: FontWeight.normal),
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(_groceryItems[index].id),
                background: Container(
                  color: Colors.red,
                ),
                movementDuration: const Duration(milliseconds: 400),
                onDismissed: (direction) {
                  _removeItem(_groceryItems[index]);
                },
                child: ListTile(
                  title: Text(_groceryItems[index].name),
                  leading: Container(
                    color: _groceryItems[index].category.color,
                    width: 24,
                    height: 24,
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ));
    }

    // if (_error != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(_error!),
    //     backgroundColor: Colors.red,
    //   ));
    // }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Your Groceries !',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: const Icon(Icons.logout_outlined)),
          IconButton(
            onPressed: () {
              _addItem();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child: content,
      ),
    );
  }
}
