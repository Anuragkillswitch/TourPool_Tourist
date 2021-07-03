import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourist_app/DataHandler/app_data.dart';
import 'package:tourist_app/DifferentScreens/search_screen.dart';
import 'package:tourist_app/DifferentWidgets/divider_widget.dart';
import 'package:tourist_app/DifferentWidgets/progress_dialog.dart';
import 'package:tourist_app/Models/direction_details.dart';
import 'package:tourist_app/assistance/assistant_methods.dart';

import '../configure_maps.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String idString = 'homescreen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  late GoogleMapController newGoogleMapController;

  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  late Position currentPosition;
  var geolocator = Geolocator();
  double bottomPaddingforMap = 0;
  double rideDetailsContainerHeight = 0; //For switching the containers
  double searchContainerHeight = 300.0; //And hiding the previous container
  double requestingRideContainerHeight = 0;

  DirectionDetails tripDirectionDetails = DirectionDetails();

  bool openDrawer =
      true; //This is to convert the menu stack button to the cross button

  late DatabaseReference rideRequestReference;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethod
        .getOnlineUserInfo(); //This will grab the info from the Firebase Real time DB
  }

  void saveRideRequest() //Saving ride info to RTDB
  {
    rideRequestReference =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickupLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocationMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocationMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocationMap,
      "dropOff": dropOffLocationMap,
      "created_at": DateTime.now().toString(),
      "tourist_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp.placeName,
      "dropOff_address": dropOff.placeName
    };

    rideRequestReference.set(rideInfoMap);
  }

  void cancelRideRequest() {
    rideRequestReference.remove(); //Removes the ride request from the database
  }

  void displayRequestRideContainerHeight() {
    setState(() {
      requestingRideContainerHeight = 200;
      rideDetailsContainerHeight = 0;
      bottomPaddingforMap = 230;
      openDrawer = true;
    });
    saveRideRequest(); //Save the info to Real time database right after the request is tapped on
  }

  void resetAppState() {
    setState(() {
      openDrawer = true;
      searchContainerHeight = 300;
      rideDetailsContainerHeight = 0;
      requestingRideContainerHeight = 0;
      bottomPaddingforMap = 230;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      polyLineCoordinates.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 250;
      bottomPaddingforMap = 230.0;
      openDrawer = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latlang = LatLng(position.latitude, position.longitude);
    //Now we need to move the camera as the position changes
    CameraPosition cameraPosition = CameraPosition(target: latlang, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String address =
        await AssistantMethod.searchCoordinateAddress(position, context);
    // print("Your address :" + address);
  }

  static const colorizeColors = [
    Color(0xFF00bfa5),
    Color(0xFF00B8D4),
    Color(0xFF00695C),
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 30,
    fontFamily: 'Bolt-Semibold',
  );

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF26a69a),
        title: const Text(
          'TourPool',
          style: TextStyle(fontSize: 24),
        ),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Image.asset(
                          "images/user_icon.png",
                          height: 65.0,
                          width: 65.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profile Name",
                              style: TextStyle(
                                  fontSize: 16.0, fontFamily: "Bolt-Semibold"),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            Text("Visit Profile"),
                          ],
                        ),
                      ],
                    )),
              ),
              DividerWidget(),
              SizedBox(
                height: 12.0,
              ),
              //Controllers for the drawer will be declared below!
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontFamily: "Bolt-Semibold", fontSize: 15),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "View Profile",
                  style: TextStyle(fontFamily: "Bolt-Semibold", fontSize: 15),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outlined),
                title: Text(
                  "About us",
                  style: TextStyle(fontFamily: "Bolt-Semibold", fontSize: 15),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut(); //Sign out on tap
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idString, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.assignment_return_rounded),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontFamily: "Bolt-Semibold", fontSize: 15),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingforMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,

            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true, //self explanatory
            zoomGesturesEnabled: true, //self explanatory
            zoomControlsEnabled: true, //self explanatory
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                bottomPaddingforMap = 265.0;
              });
              _controllerGoogleMaps.complete(controller);
              newGoogleMapController = controller;
              locatePosition();
            },
          ),

          //menu button for drawer
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                openDrawer
                    ? scaffoldKey.currentState!.openDrawer()
                    : resetAppState();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (openDrawer) ? Icons.menu : Icons.close_outlined,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFF26a69a),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 6.0,
                      ),
                      Text(
                        "Hi There! ",
                        style: TextStyle(fontSize: 14.0),
                      ),
                      Text(
                        "Where to?",
                        style: TextStyle(
                            fontSize: 24.0, fontFamily: "Bolt-Semibold"),
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                          if (res == "obtainDirection") {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.6, 4.7),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 18.0),
                              DividerWidget(),
                              DividerWidget(),
                              Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 28,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                "Find Drop point",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DividerWidget(),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      SizedBox(height: 18.0),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context).pickupLocation !=
                                        null
                                    ? Provider.of<AppData>(context)
                                        .pickupLocation
                                        .placeName
                                    : "Add Home",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Wherever you're staying...",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.0,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      SizedBox(height: 17.0),
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Secondary address",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Going somewhere often?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.0,
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.teal.shade500,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 21.0),
                          child: Column(
                            children: [
                              DividerWidget(),
                              DividerWidget(),
                              Row(
                                children: [
                                  Image.asset(
                                    "images/taxi.png",
                                    height: 70.0,
                                    width: 80.0,
                                  ),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Car",
                                        style: TextStyle(
                                            fontSize: 22.0,
                                            fontFamily: "Bolt-Semibold"),
                                      ),
                                      Text(
                                        (tripDirectionDetails != null)
                                            ? tripDirectionDetails.distanceText
                                            : '',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "Bolt-Semibold",
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    ((tripDirectionDetails != null)
                                        ? '\u{20B9}${AssistantMethod.calculateFare(tripDirectionDetails)}'
                                        : ''),
                                    style:
                                        TextStyle(fontFamily: "Bolt-Semibold"),
                                  )
                                ],
                              ),
                              DividerWidget(),
                              DividerWidget(),
                              DividerWidget(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyBillWave,
                              size: 20.0,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Text(
                              "Cash",
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black,
                              size: 20.0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            displayRequestRideContainerHeight();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Request",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.redAccent,
                                  size: 26.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ), //Ride details tab

          //Following is the finding rides pop-up that would appear after route and request is chosen

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: requestingRideContainerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)),
                color: Colors.black45,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    spreadRadius: 0.5,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            '    \t  Requesting Ride',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                          ),
                          ColorizeAnimatedText(
                            '     \t  Hold on...',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                          ),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {
                          print("Tap Event");
                        },
                      ),
                    ),
                    SizedBox(height: 25),
                    GestureDetector(
                      onTap: () {
                        cancelRideRequest();
                        resetAppState();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.teal.shade400,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(width: 2.0, color: Colors.black12)),
                        child: Icon(
                          Icons.close,
                          size: 36.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Cancel Ride search",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: "Bolt-Semibold",
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickupLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickupLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait..."));

    var details =
        await AssistantMethod.obtainDirection(pickupLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    print("These are the encoded points" + details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePoints =
        polylinePoints.decodePolyline(details.encodedPoints);
    polyLineCoordinates.clear();
    if (decodedPolylinePoints.isNotEmpty) {
      decodedPolylinePoints.forEach((PointLatLng pointLatLng) {
        polyLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.deepPurpleAccent,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLineCoordinates,
        width: 5,
        startCap: Cap.buttCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickupLatLng.latitude > dropOffLatLng.latitude &&
        pickupLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickupLatLng.longitude),
          northeast: LatLng(pickupLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickupLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickupLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      position: pickupLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Destination"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickupLocationMarker);
      markersSet.add(dropOffLocationMarker);
    });
    Circle pickupLocationCircle = Circle(
      fillColor: Colors.black,
      center: pickupLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.black54,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocationCircle = Circle(
      fillColor: Colors.pinkAccent,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.purpleAccent,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickupLocationCircle);
      circlesSet.add(dropOffLocationCircle);
    });
  }
}
