import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:resize/resize.dart';
import 'package:planner/supabase.dart';

var email = null;
var signedin = "You";
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

void SaveUserInfo(email) {
  GetStorage().write("signed_in_email", email);
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
              _navigateToNextScreen(context);
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
              
            },
            color: Colors.cyan,
            text: "Next",
            icon: Icon(
              Icons.forward,
              color: Colors.white,
            ),
          ),
        ]
       ),
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
              onPressed: () {},
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

class NewPage3 extends StatefulWidget {
  const NewPage3({Key? key}) : super(key: key);
  @override
  _NewPage3State createState() => _NewPage3State();
}

class _NewPage3State extends State<NewPage3> {
  TextEditingController kidnameController = new TextEditingController();
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
        title: const Text('Child details'),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Child Name',
              textScaleFactor: 3,
              style: TextStyle(color: Colors.cyan),
            ),
            SizedBox(height: 0.5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextField(
                controller: kidnameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter child name',
                ),
              ),
            ),
            SizedBox(height: 0.5),
            GFButton(
              onPressed: () {
                if (int.parse(GetStorage().read('kid_number')) == 3) {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => GFFloatingWidget(
                      child: GFAlert(
                        title: 'Error',
                        content: 'Child limit reached',
                        bottombar: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GFButton(
                                shape: GFButtonShape.pills,
                                color: Colors.cyan,
                                child: Text('OK',
                                    style: TextStyle(color: Colors.black)),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => NewPage1()));
                                },
                              ),
                            ]),
                      ),
                    ),
                  );
                } else {
                  var kid_number = int.parse(GetStorage().read('kid_number'));
                  kid_number = kid_number + 1;
                  var children = GetStorage().write(
                      'kid_' + kid_number.toString(), kidnameController.text);
                }
              },
              color: Colors.cyan,
              text: "Submit",
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
                  setState(() {
                    email = GetStorage().read("signed_in_email");
                    signedin = "You";
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));
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
                  setState(() {
                    email = GetStorage().read("signed_in_email");
                    signedin = "You";
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));
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
