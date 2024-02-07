import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Property Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => MyHomePage(),
        '/addProperty': (context) => AddPropertyPage(),
        '/propertyList': (context) => PropertyListPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                await loginUser(emailController.text, passwordController.text);
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("http://sectorplot.000webhostapp.com/login.php"),
        body: {
          "email": email,
          "password": password,
        },
      );

      var data = json.decode(response.body);
      if (data['success']) {
        // Navigate to home page or any other page after successful login
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to login. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController(); // Add this controller
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: usernameController, // Add this TextField for username
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                await registerUser(emailController.text, usernameController.text, passwordController.text); // Modify this line to include the username
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser(String email, String username, String password) async { // Modify this function signature
    try {
      final response = await http.post(
        Uri.parse("http://sectorplot.000webhostapp.com/register.php"),
        body: {
          "email": email,
          "username": username, // Add this line for username
          "password": password,
        },
      );

      var data = json.decode(response.body);
      if (data['success']) {
        // Show success message or navigate to login page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to login page after successful registration
        Navigator.pushReplacementNamed(context, '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Add Property'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/addProperty');
              },
            ),
            ListTile(
              title: Text('View Properties'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/propertyList');
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                logoutUser(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          height: 150.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              HomeCard(
                title: 'Add Property',
                icon: Icons.add,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/addProperty');
                },
              ),
              HomeCard(
                title: 'View Properties',
                icon: Icons.list,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/propertyList');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> logoutUser(BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse("http://sectorplot.000webhostapp.com/logout.php"),
    );
    var data = json.decode(response.body);
    if (data['success']) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      throw Exception(data['message']);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to logout. Please try again later.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 150.0,
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyListPage extends StatefulWidget {
  @override
  _PropertyListPageState createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  List<dynamic> properties = [];
  List<dynamic> filteredProperties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final response = await http.get(
        Uri.parse("http://sectorplot.000webhostapp.com/getdata1.php"),
      );
      if (response.statusCode == 200) {
        setState(() {
          properties = json.decode(response.body);
          filteredProperties = List.from(properties);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      showErrorSnackBar('Failed to fetch data. Please try again later.');
    }
  }

  Future<void> refreshData() async {
    // Simulate a delay for demonstration purposes
    await Future.delayed(Duration(seconds: 1));
    await getData();
  }

  Future<void> deleteData(int propertyID, int index) async {
    try {
      setState(() {
        properties.removeAt(index);
        filteredProperties.removeAt(index);
      });

      final response = await http.post(
        Uri.parse("http://sectorplot.000webhostapp.com/deletedata1.php"),
        body: {
          "propertyID": propertyID.toString(),
        },
      );

      var data = json.decode(response.body);
      if (!data['success']) {
        throw Exception(data['message']);
      }
      showSuccessSnackBar(data['message']);
    } catch (e) {
      setState(() {
        properties.insert(index, properties[index]);
        filteredProperties.insert(index, properties[index]);
      });
      showErrorSnackBar('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Properties'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : properties.isEmpty
          ? Center(
        child: Text(
          'No properties available',
          style: TextStyle(fontSize: 16.0),
        ),
      )
          : RefreshIndicator(
        onRefresh: refreshData,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    filteredProperties = properties
                        .where((property) => property['Sector']
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search Sector',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  return PropertyCard(
                    property: filteredProperties[index],
                    onDelete: () async {
                      await deleteData(
                          int.parse(properties[index]['PropertyID']),
                          index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final dynamic property;
  final VoidCallback onDelete;

  const PropertyCard({required this.property, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PropertyDetailsPage(property: property),
              ),
            );
          },
          child: Text(property['Name']),
        ),
        subtitle: Text(property['Type']),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class PropertyDetailsPage extends StatelessWidget {
  final dynamic property;

  const PropertyDetailsPage({required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property['Name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${property['Type']}'),
            Text('Size: ${property['Size']}'),
            Text('Sector: ${property['Sector']}'),
            Text('Mobile: ${property['Mobile']}'),
            Text('Email: ${property['Email']}'),
            Text('Approximate Rate: ${property['ApproxRate']}'),
          ],
        ),
      ),
    );
  }
}

class AddPropertyPage extends StatefulWidget {
  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController sectorController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController approxRateController = TextEditingController();

  final List<String> propertyTypes = ['Flat', 'Plot'];
  String selectedType = 'Flat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Property'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            DropdownButtonFormField(
              value: selectedType,
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue.toString();
                });
              },
              items: propertyTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Type',
              ),
            ),
            TextField(
              controller: sizeController,
              decoration: InputDecoration(
                labelText: 'Size',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: sectorController,
              decoration: InputDecoration(
                labelText: 'Sector',
              ),
            ),
            TextField(
              controller: mobileController,
              decoration: InputDecoration(
                labelText: 'Mobile',
              ),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: approxRateController,
              decoration: InputDecoration(
                labelText: 'Approximate Rate',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (_validateInputs()) {
                  await sendData();
                }
              },
              child: Text('Add Property'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        sizeController.text.isEmpty ||
        sectorController.text.isEmpty ||
        mobileController.text.isEmpty ||
        emailController.text.isEmpty ||
        approxRateController.text.isEmpty) {
      _showValidationError('All fields are required.');
      return false;
    }

    if (!emailController.text.contains('@')) {
      _showValidationError('Invalid email address.');
      return false;
    }

    if (double.tryParse(sizeController.text) == null ||
        double.tryParse(approxRateController.text) == null) {
      _showValidationError('Size and Approximate Rate must be valid numbers.');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> sendData() async {
    try {
      final response = await http.post(
        Uri.parse("http://sectorplot.000webhostapp.com/insertdata1.php"),
        body: {
          "name": nameController.text,
          "type": selectedType,
          "size": sizeController.text,
          "sector": sectorController.text,
          "mobile": mobileController.text,
          "email": emailController.text,
          "approxRate": approxRateController.text,
        },
      );

      var data = json.decode(response.body);
      if (!data['success']) {
        throw Exception(data['message']);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor: Colors.green,
        ),
      );
      // Clear text fields after successful addition
      nameController.clear();
      sizeController.clear();
      sectorController.clear();
      mobileController.clear();
      emailController.clear();
      approxRateController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
