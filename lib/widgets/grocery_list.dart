import 'package:flutter/Material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.push<GroceryItem>(
        context, MaterialPageRoute(builder: (ctx) => const NewItem()));
    if (newItem == null) return;
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Groceries !',
          style: Theme
              .of(context)
              .textTheme
              .titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              _addItem();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: (_groceryItems.isEmpty)
          ? Center(
        child: Text('Add some groceries!', style: Theme
            .of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Colors.blueGrey, fontWeight: FontWeight.normal),),
      )
          : ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) =>
              Dismissible(
                key: ValueKey(_groceryItems[index].id),
                background: Container(
                  color: Colors.red,
                ),
                movementDuration: const Duration(milliseconds: 400),
                onDismissed: (direction) {
                  setState(() {
                    _groceryItems.remove(_groceryItems[index]);
                  });
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
              )),
    );
  }
}
