import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

void main() async{
  await DotEnv().load('.env');
  runApp(RestaurantSearchApp());
}

class RestaurantSearchApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SearchPage(title: 'Restaurant App'),
    );
  }
}

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;

  final dio = Dio(BaseOptions(
    baseUrl: 'https://developers.zomato.com/api/v2.1/search',
    headers: {
      'user-key': DotEnv().env['ZOMATO_API_KEY'],
    },
  ));

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

List _restaurants;
void searchRestaurants(String query) async {
  final response = await widget.dio.get('', queryParameters: {
    'q': query,
  });
  setState(() {
  _restaurants = response.data['restaurants'];
  });
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SearchForm(
              onSearch: searchRestaurants,
            ),
              _restaurants == null ? Text('No results to display') : Expanded(
                child: ListView(children: _restaurants.map((restaurant) {
                return ListTile(
                  title: Text(restaurant['restaurant']['name']),
                  subtitle: Text(restaurant['restaurant']['location']['address']),
                  trailing: Text('${restaurant['restaurant']['user_rating']['aggregate_rating']} stars'),
                );
              }).toList(),
              ),
              ),
          ],
        ),
      ), 
    );
  }
}
class SearchForm extends StatefulWidget {
  SearchForm({ this.onSearch });

  final void Function(String search) onSearch;
  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final _formkey = GlobalKey<FormState>();
  var _autoValidate = false;
  var _search;
  @override
  Widget build(BuildContext context) {
    return     Form(
              key: _formkey,
              autovalidate: _autoValidate,
              child: Column(children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Enter search',
                    filled: true,
                    errorStyle: TextStyle(fontSize: 15),
                  ),
                  onChanged: (value) {
                      _search = value;
                  },
                  validator: (value)  {
                    if(value.isEmpty)
                    {
                      return 'Please Enter a Search Item';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,

                child: RawMaterialButton(onPressed: () {
                  final isValid = _formkey.currentState.validate();
                  if (isValid)
                  {
                      widget.onSearch(_search);
                  }
                  else
                  {
                    setState(() {
                      _autoValidate = true;
                    });
                  }
                }, 
                fillColor: Colors.red,
                child: Padding(padding: const EdgeInsets.all(15),
                child: Text('Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),),
                ),
                ),
                ),
              ],),
              );
  }
}