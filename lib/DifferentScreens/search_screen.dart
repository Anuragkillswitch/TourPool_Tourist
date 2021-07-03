import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourist_app/DataHandler/app_data.dart';
import 'package:tourist_app/DifferentWidgets/divider_widget.dart';
import 'package:tourist_app/DifferentWidgets/progress_dialog.dart';
import 'package:tourist_app/Models/address.dart';
import 'package:tourist_app/Models/places_autocomplete.dart';
import 'package:tourist_app/assistance/request_assistant.dart';

import '../configure_maps.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress = Provider.of<AppData>(context)
        .pickupLocation
        .placeName; //If it contains any data
    pickUpTextEditingController.text = placeAddress;
    return Scaffold(
      body: Column(
        children: [
          SingleChildScrollView(
            child: Container(
              height: 260.0,
              decoration: BoxDecoration(color: Colors.black26, boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ]),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.0, top: 70.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(
                                context); //This will send the user back to the main screen
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 40,
                          ),
                        ),
                        Center(
                            child: Text(
                          "Set destination",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Bolt-Semibold",
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/pickicon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          height: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                  hintText: "Pickup Location",
                                  fillColor: Colors.blueGrey,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/desticon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          height: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                onChanged: (val) {
                                  findPlace(val);
                                },
                                controller: dropOffTextEditingController,
                                decoration: InputDecoration(
                                  hintText: "Set Destination",
                                  fillColor: Colors.blueGrey,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Tile for predictions

          SizedBox(height: 10.0),
          (placePredictionList.isNotEmpty)
              ? Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: ListView.separated(
                        padding: EdgeInsets.all(0.0),
                        itemBuilder: (context, index) {
                          return PredictionTile(
                              placePredictions: placePredictionList[index]);
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            DividerWidget(),
                        itemCount: placePredictionList.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autocompleteURL =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&component=country:in";
      var res = await RequestAssistant.getRequest(autocompleteURL);

      if (res == "failed") {
        return;
      } else {
        if (res["status"] == "OK") {
          var predictions = res["predictions"];

          var placeList = (predictions as List)
              .map((e) => PlacePredictions.fromJson(e))
              .toList();
          setState(() {
            placePredictionList = placeList;
          });
        }
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  const PredictionTile({Key? key, required this.placePredictions})
      : super(key: key);
  final PlacePredictions placePredictions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: TextButton(
        onPressed: () {
          getPlaceAddressDetails(placePredictions.place_id!, context);
        },
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Icon(Icons.add_location),
                  SizedBox(
                    width: 14.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          placePredictions.main_text!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                        Text(
                          placePredictions.secondary_text!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeID, BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Setting Drop-off Please wait",
            ));

    String placeDetailsURL =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$mapKey";
    var res = await RequestAssistant.getRequest(placeDetailsURL);

    Navigator.pop(context);

    if (res == "failed") return;

    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeID = placeID;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);

      print("This is the drop off location : " + address.placeName);
      Navigator.pop(context, "obtainDirection");
    }
  }
}
