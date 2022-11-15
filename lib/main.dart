import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:resize/resize.dart';
import 'package:planner/supabase.dart';

var email = "null";
var signedin = "You";
var task_email = "null";
var task_array_filled_number = -1;

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  if (GetStorage().read("signed_in_email") != null &&
      GetStorage().read("signed_in_email") != "signed_out") {
    email = GetStorage().read("signed_in_email");
    signedin = "You";
  } else {
    email = "Email Unknown";
    signedin = "Not Signed In";
  }
  runApp(MyApp());
}

void SaveUserInfo(mail) {
  GetStorage().write("signed_in_email", mail);
  email = GetStorage().read("signed_in_email").toString();
  signedin = "You";
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Resize(
      builder: () {
        return MaterialApp(
          title: 'TaskGenix',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.greenAccent[400],
    );
    final ButtonStyle style1 = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.cyanAccent[400],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.cyan,
      ),
      drawer: GFDrawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            GFDrawerHeader(
              decoration: BoxDecoration(color: Colors.cyan),
              currentAccountPicture: GFAvatar(
                radius: 80.0,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('user.png'),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    signedin,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(email, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: GFButton(
                  shape: GFButtonShape.pills,
                  color: Colors.cyan,
                  child: Text('Sign In', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignInScreen()));
                  }),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => TodoList()));
            },
            style: style,
            child: Text(
              'See Tasks',
              textScaleFactor: 3,
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _navigateToNextScreen(context);
            },
            style: style1,
            child: Text(
              'Assign Tasks',
              textScaleFactor: 3,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewPage()));
  }
}

class NewPage extends StatefulWidget {
  const NewPage({Key? key}) : super(key: key);
  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  TextEditingController passwordController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.redAccent[400],
    );
    final ButtonStyle style1 = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.cyanAccent[400],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password'),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(
            'Enter the password',
            textScaleFactor: 3,
            style: TextStyle(color: Colors.cyan),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter password',
              ),
            ),
          ),
          GFButton(
            onPressed: () {
              if (GetStorage().read('parent_password') == null) {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text(
                        'Do you confirm the password? It will be saved in your device.'),
                    actions: <Widget>[
                      TextButton(
                        style: style,
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        style: style1,
                        onPressed: () {
                          savepass(passwordController.text);
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                final pass_entered = passwordController.text;
                if (pass_entered == GetStorage().read('parent_password')) {
                  _navigateToNextScreen(context);
                } else {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => GFFloatingWidget(
                      child: GFAlert(
                        contentTextStyle: TextStyle(
                          color: Colors.cyan,
                          decoration: TextDecoration.none,
                        ),
                        titleTextStyle: TextStyle(
                            color: Colors.cyan,
                            decoration: TextDecoration.none),
                        title: 'Error',
                        content: 'Invalid Password',
                        bottombar: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GFButton(
                                shape: GFButtonShape.pills,
                                color: Colors.cyan,
                                child: Text('OK',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => NewPage()));
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              GFButton(
                                shape: GFButtonShape.pills,
                                color: Colors.blueGrey,
                                child: Text('Cancel',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MyHomePage()));
                                },
                              ),
                            ]),
                      ),
                    ),
                  );
                }
              }
            },
            color: Colors.cyan,
            text: "Next",
            icon: Icon(
              Icons.forward,
              color: Colors.white,
            ),
          ),
        ]),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewPage1()));
  }

  void savepass(password) {
    GetStorage().write('parent_password', password);
    _navigateToNextScreen(context);
  }
}

class NewPage1 extends StatefulWidget {
  const NewPage1({Key? key}) : super(key: key);
  @override
  _NewPage1State createState() => _NewPage1State();
}

class _NewPage1State extends State<NewPage1> {
  @override
  Widget build(BuildContext context) {
    TextEditingController userController = new TextEditingController();
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.redAccent[400],
    );
    final ButtonStyle style1 = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.cyanAccent[400],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Tasks'),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(
            'Assign a task',
            textScaleFactor: 3,
            style: TextStyle(color: Colors.cyan),
          ),
          SizedBox(height: 0.5),
          Text(
            'Enter Email Id of the person',
            textScaleFactor: 2,
            style: TextStyle(color: Colors.cyan),
          ),
          SizedBox(height: 0.5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: TextField(
              controller: userController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter email id',
              ),
            ),
          ),
          SizedBox(height: 0.5),
          GFButton(
            onPressed: () {
              task_email = userController.text;
              _navigateToNextScreen(context);
            },
            color: Colors.cyan,
            text: "Next",
            icon: Icon(
              Icons.forward,
              color: Colors.white,
            ),
          ),
        ]),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewPage2()));
  }
}

class NewPage2 extends StatefulWidget {
  const NewPage2({Key? key}) : super(key: key);
  @override
  _NewPage2State createState() => _NewPage2State();
}

class _NewPage2State extends State<NewPage2> {
  TextEditingController tasknameController = new TextEditingController();
  TextEditingController taskdetailsController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    //getkidview();
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.redAccent[400],
    );
    final ButtonStyle style1 = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.cyanAccent[400],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Task Name',
              textScaleFactor: 3,
              style: TextStyle(color: Colors.cyan),
            ),
            SizedBox(height: 0.5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextField(
                controller: tasknameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter task name',
                ),
              ),
            ),
            SizedBox(height: 0.5),
            Text(
              'Task Details',
              textScaleFactor: 3,
              style: TextStyle(color: Colors.cyan),
            ),
            SizedBox(height: 0.5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextField(
                controller: taskdetailsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter task details',
                ),
              ),
            ),
            SizedBox(height: 0.5),
            GFButton(
              onPressed: () {
                SendAsEmail(email, task_email, taskdetailsController.text);
              },
              color: Colors.cyan,
              text: "Assign",
              icon: Icon(
                Icons.forward,
                color: Colors.white,
              ),
              shape: GFButtonShape.pills,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MyHomePage()));
  }
}

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController emailpasswordController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => MyHomePage()));
        },
        backgroundColor: Colors.cyan,
        tooltip: 'Add Item',
        child: Icon(Icons.close),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
            ],
          ),
        ),
        child: Card(
          margin: EdgeInsets.only(top: 30, bottom: 30, left: 30, right: 30),
          elevation: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Sign In to continue",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
              SizedBox(height: 0.5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter email',
                  ),
                ),
              ),
              SizedBox(height: 0.5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextField(
                  controller: emailpasswordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter password',
                  ),
                ),
              ),
              SizedBox(height: 0.5),
              GFButton(
                onPressed: () {
                  LoginUser(emailController.text, emailpasswordController.text);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
                color: Colors.cyan,
                text: "Login In",
                icon: Icon(
                  Icons.login,
                  color: Colors.white,
                ),
                shape: GFButtonShape.pills,
              ),
              SizedBox(height: 10),
              GFButton(
                onPressed: () {
                  CreateUser(
                      emailController.text, emailpasswordController.text);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
                color: Colors.cyan,
                text: "Sign Up",
                icon: Icon(
                  Icons.forward,
                  color: Colors.white,
                ),
                shape: GFButtonShape.pills,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // save data
  final List<String> _todoList = <String>[];
  // text field
  final TextEditingController _textFieldController = TextEditingController();
  //counter
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        backgroundColor: Colors.cyan,
      ),
      body: ListView(children: _getItems()),
      // add items to the to-do list
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context),
          backgroundColor: Colors.cyan,
          tooltip: 'Add Item',
          child: Icon(Icons.add)),
    );
  }

  void _addTodoItem(String title) {
    // Wrapping it inside a set state will notify
    // the app that the state has changed
    setState(() {
      _todoList.add(title);
      _incrementCounter();
    });
    _textFieldController.clear();
  }

  void _removeTodoItem(String title) {
    // Wrapping it inside a set state will notify
    // the app that the state has changed
    setState(() {
      _todoList.remove(title);
      _decrementCounter();
    });
    _textFieldController.clear();
  }

  // this Generate list of item widgets
  Widget _buildTodoItem(String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        _removeTodoItem(title);
      },
    );
  }

  void _incrementCounter() {
    setState(() {
      counter++;
      if(counter == 0) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPage3()));
      }
    });
  }

  void _decrementCounter() {
    setState(() {
      counter--;
      if(counter == 0) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPage3()));
      }
    });
  }

  // display a dialog for the user to enter items
  Future<dynamic> _displayDialog(BuildContext context) async {
    // alter the app state to show a dialog
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add a task to your list'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: 'Enter task here'),
            ),
            actions: <Widget>[
              // add button
              GFButton(
                color: Colors.cyan,
                child: const Text('ADD'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _addTodoItem(_textFieldController.text);
                },
              ),
              GFButton(
                color: Colors.cyan,
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  List<Widget> _getItems() {
    final List<Widget> _todoWidgets = <Widget>[];
    for (String title in _todoList) {
      _todoWidgets.add(_buildTodoItem(title));
    }
    return _todoWidgets;
  }
}

class NewPage3 extends StatefulWidget {
  const NewPage3({Key? key}) : super(key: key);
  @override
  _NewPage3State createState() => _NewPage3State();
}

class _NewPage3State extends State<NewPage3> {
  TextEditingController rewardnameController = new TextEditingController();
  TextEditingController rewardurlController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.redAccent[400],
    );
    final ButtonStyle style1 = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 14),
      primary: Colors.cyanAccent[400],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Reward Email id',
              textScaleFactor: 3,
              style: TextStyle(color: Colors.cyan),
            ),
            SizedBox(height: 0.5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextField(
                controller: rewardnameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter email id',
                ),
              ),
            ),
            SizedBox(height: 0.5),
            Text(
              'Reward link',
              textScaleFactor: 3,
              style: TextStyle(color: Colors.cyan),
            ),
            SizedBox(height: 0.5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextField(
                controller: rewardurlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter link',
                ),
              ),
            ),
            SizedBox(height: 0.5),
            GFButton(
              onPressed: () {
                SendAsEmail(email, rewardnameController.text, rewardurlController.text);
              },
              color: Colors.cyan,
              text: "Assign",
              icon: Icon(
                Icons.forward,
                color: Colors.white,
              ),
              shape: GFButtonShape.pills,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MyHomePage()));
  }
}
