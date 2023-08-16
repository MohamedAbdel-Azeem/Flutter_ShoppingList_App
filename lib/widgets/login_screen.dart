import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/widgets/grocery_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  var _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  var _isSending = false;

  var _enteredUsername = '';
  var _enteredPassword = '';

  Future<bool> _validateUsername() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    _formKey.currentState!.save();

    final url = Uri.https(
        'flutter-shopping-list-ap-fc113-default-rtdb.firebaseio.com',
        'shopping-list-usernames.json');
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cannot connect to server!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
      return false;
    }
    if (response.body == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No usernames!'),
        backgroundColor: Colors.yellow,
        duration: Duration(seconds: 3),
      ));
      return false;
    }

    final Map<String, dynamic> usersData = json.decode(response.body);

    final user = usersData.entries
        .where((user) => user.value['username'] == _enteredUsername);
    if (user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Username is not recognized!'),
        backgroundColor: Colors.yellow,
        duration: Duration(seconds: 3),
      ));
      return false;
    }

    if (user.first.value['password'] != _enteredPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password or Username is incorrect, please Check!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
      return false;
    }
    return true;
  }

  void _logIn() async {
    setState(() {
      _isSending = true;
    });
    if (await _validateUsername()) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => GroceryList(
                username: _enteredUsername,
              )));
    }
    setState(() {
      _isSending = false;
    });
    _formKey.currentState!.reset();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      print('valid!');
      _formKey.currentState!.save();
      final url = Uri.https(
          'flutter-shopping-list-ap-fc113-default-rtdb.firebaseio.com',
          'shopping-list-usernames.json');

      final responseGet = await http.get(url);
      if (responseGet.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot connect to server!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        return;
      }

      if (responseGet.body != 'null') {
        final Map<String, dynamic> usersData = json.decode(responseGet.body);

        for (final user in usersData.entries) {
          if (user.value['username'] == _enteredUsername) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('This username is already used!'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ));
            return;
          }
        }
      }

      final responsePost = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': _enteredUsername,
          'password': _enteredPassword,
        }),
      );

      setState(() {
        _isSending = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sign-up successful'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ));
      _logIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log-in!'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
        child: Card(
          elevation: 6,
          color: const Color.fromARGB(255, 50, 51, 65),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        label: Text('Username',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(fontSize: 24)),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        prefixText: 'Username: '),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 2) {
                        return 'Invalid Username!';
                      }
                      return null;
                    },
                    onSaved: (value) => _enteredUsername = value!,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        label: Text('Password',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(fontSize: 24)),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        prefixText: 'Password: ',
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: const Icon(
                              Icons.remove_red_eye,
                              size: 20,
                            ))),
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 2) {
                        return 'Invalid Username!';
                      }
                      return null;
                    },
                    onSaved: (value) => _enteredPassword = value!,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextButton(
                      onPressed: _isSending ? null : _signUp,
                      child: _isSending
                          ? const CircularProgressIndicator()
                          : const Text('Sign-Up')),
                  ElevatedButton(
                      onPressed: _isSending ? null : _logIn,
                      child: _isSending
                          ? const CircularProgressIndicator()
                          : const Text('Log-in'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
