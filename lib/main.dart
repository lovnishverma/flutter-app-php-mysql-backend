import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

final ThemeData lightTheme = ThemeData.light().copyWith(
  // Define your light theme properties here
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  // Add other properties as needed
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  // Define your dark theme properties here
  brightness: Brightness.dark,
  primaryColor: Colors.indigo,
  // Add other properties as needed
);

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightTheme;

  ThemeProvider() {
    _loadThemeFromPreferences(); // Load theme from shared preferences
  }

  ThemeData getTheme() => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    _saveThemeToPreferences(themeData); // Save theme to shared preferences
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightTheme) {
      setTheme(darkTheme);
    } else {
      setTheme(lightTheme);
    }
  }

  void _loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt('theme') ?? 0;
    _themeData = themeIndex == 0 ? lightTheme : darkTheme;
    notifyListeners();
  }

  void _saveThemeToPreferences(ThemeData themeData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('theme', themeData == lightTheme ? 0 : 1);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Property Management App',
      theme: themeProvider.getTheme(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return PageTransition(
          child: _getPage(settings),
          type: PageTransitionType.rightToLeft,
        );
      },
          );
        },
    );
  }

  Widget _getPage(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return LoginPage();
      case '/home':
        return MyHomePage();
      case '/addProperty':
        return AddPropertyPage();
      case '/propertyList':
        return PropertyListPage();
      case '/register':
        return RegisterPage();
      case '/latestUpdates':
        return LatestUpdatesPage();
      default:
        return Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        );
    }
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _getStoredCredentials();
  }

  Future<void> _getStoredCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _storeCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      prefs.setString('email', emailController.text);
      prefs.setString('password', passwordController.text);
      prefs.setBool('rememberMe', true);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.remove('rememberMe');
    }
  }

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
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                ),
                Text('Remember Me'),
              ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Click here to register'),
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
        // Store credentials if "Remember Me" is selected
        await _storeCredentials();

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
          "username": username,
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
          actions: [
      IconButton(
      icon: Icon(Icons.lightbulb),
      onPressed: () {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      },
      ),
          ],
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
              leading: Icon(Icons.map),
              title: Text('Sector at a Glance'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Sector at a Glance page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SectorAtGlancePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('View Properties'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/propertyList');
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Property'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/addProperty');
              },
            ),
            ListTile(
              leading: Icon(Icons.update),
              title: Text('Latest Updates/Projects'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Latest Updates/Projects page
                Navigator.pushNamed(context, '/latestUpdates');
              },
            ),
            Divider(), // Add a divider for visual separation
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                logoutUser(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
          children: [
            _buildDashboardItem(
              title: 'Sector at a Glance',
              icon: Icons.map,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SectorAtGlancePage()),
                );
              },
            ),
            _buildDashboardItem(
              title: 'View Properties',
              icon: Icons.list,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/propertyList');
              },
            ),
            _buildDashboardItem(
              title: 'Add Property',
              icon: Icons.add,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/addProperty');
              },
            ),
            _buildDashboardItem(
              title: 'Latest Updates/Projects',
              icon: Icons.assignment,
              color: Colors.purple,
              onTap: () {
                // Navigate to the Latest Updates/Projects page
                Navigator.pushNamed(context, '/latestUpdates');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LatestUpdatesPage extends StatefulWidget {
  @override
  _LatestUpdatesPageState createState() => _LatestUpdatesPageState();
}

class _LatestUpdatesPageState extends State<LatestUpdatesPage> {
  List<dynamic> updates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUpdates();
  }

  Future<void> fetchUpdates() async {
    try {
      final response = await http.get(
        Uri.parse("http://sectorplot.000webhostapp.com/fetch_latest_updates.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          updates = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load updates');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latest Updates/Projects'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : updates.isEmpty
          ? Center(
        child: Text(
          'No updates available',
          style: TextStyle(fontSize: 16.0),
        ),
      )
          : ListView.builder(
        itemCount: updates.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 3,
              child: ListTile(
                title: Text(
                  updates[index]['title'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    updates[index]['description'],
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SectorAtGlancePage extends StatefulWidget {
  @override
  _SectorAtGlancePageState createState() => _SectorAtGlancePageState();
}

class _SectorAtGlancePageState extends State<SectorAtGlancePage> {
  List<Map<String, dynamic>> sectors = [];
  List<Map<String, dynamic>> filteredSectors = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSectorDetails();
  }

  Future<void> fetchSectorDetails() async {
    try {
      final response = await http.get(
        Uri.parse("http://sectorplot.000webhostapp.com/getsectors1.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          sectors = json.decode(response.body).cast<Map<String, dynamic>>();
          filteredSectors = List.from(sectors);
        });
      } else {
        throw Exception('Failed to load sector details');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void filterSectors(String query) {
    setState(() {
      filteredSectors = sectors
          .where((sector) => sector['Sector'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sector at a Glance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterSectors(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Sector',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSectors.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text('Sector: ${filteredSectors[index]['Sector']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Property Count: ${filteredSectors[index]['PropertyCount']}'),
                        Text('Average Size: ${filteredSectors[index]['AvgSize']}'),
                        Text('Plot Count: ${filteredSectors[index]['PlotCount']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsPage(property: property),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8),
        child: ListTile(
          title: Text(property['Name']),
          subtitle: Text(property['Type']),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
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
            _buildPropertyDetailRow('Type', property['Type'], Icons.home),
            _buildPropertyDetailRow(
                'Size', '${property['Size']} ${property['size_unit']}', Icons.aspect_ratio),
            _buildPropertyDetailRow(
                'Sector', property['Sector'], Icons.location_on),
            _buildPropertyDetailRow(
                'Mobile', property['Mobile'], Icons.phone),
            _buildPropertyDetailRow(
                'Email', property['Email'], Icons.email),
            _buildPropertyDetailRow(
                'Approximate Rate', '₹${property['ApproxRate']}', Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetailRow(String label, String value, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, size: 24),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
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

  final List<String> sizeUnits = ['Sq. Feet', 'Sq. Yards', 'Sq. Meters'];
  String selectedSizeUnit = 'Sq. Feet';

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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: sizeController,
                    decoration: InputDecoration(
                      labelText: 'Size',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField(
                    value: selectedSizeUnit,
                    onChanged: (newValue) {
                      setState(() {
                        selectedSizeUnit = newValue.toString();
                      });
                    },
                    items: sizeUnits.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Unit',
                    ),
                  ),
                ),
              ],
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
          "size_unit": selectedSizeUnit,
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