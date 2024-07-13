import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:ww_code/aesthetics/textfield_style.dart';

class LocationAutoComplete extends StatefulWidget {
  const LocationAutoComplete({super.key});

  @override
  LocationAutoCompleteState createState() => LocationAutoCompleteState();
}

class LocationAutoCompleteState extends State<LocationAutoComplete> {
  String? countryName;
  final searchController = TextEditingController();
  final String token = '1234567890';
  var uuid = const Uuid();
  List<dynamic> listOfLocation = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      _onChange();
    });
  }

  _onChange() {
    placeSuggestion(searchController.text);
  }

  void placeSuggestion(String input) async {
    const String apiKey = "AIzaSyB3dkvAT_hUG51l98FOsmqE0FVS5xwqCcI";
    try {
      String baseUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = '$baseUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = data['predictions'];
        });
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Location"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.black),
              controller: searchController,
              cursorColor: Colors.black,
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Search a location...',
                prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black45,
                      ),
              ),
            ),
            Visibility(
              visible: searchController.text.isNotEmpty,
              child: Expanded(
                child: ListView.builder(
                  itemCount: listOfLocation.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, listOfLocation[index]["description"]);
                      },
                      child: ListTile(
                        title: Text(listOfLocation[index]["description"]),
                      ),
                    );
                  },
                ),
              ),
            ),
            Visibility(
              visible: searchController.text.isEmpty,
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/map.png', 
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Search for a location and \nnavigate to it on the map!',
                      style: TextStyle(
                        fontSize: 18,
                       
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}