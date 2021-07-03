import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourist_app/DataHandler/app_data.dart';
import 'package:tourist_app/Models/address.dart';
import 'package:tourist_app/Models/all_users.dart';
import 'package:tourist_app/Models/direction_details.dart';
import 'package:tourist_app/assistance/request_assistant.dart';
import 'package:tourist_app/configure_maps.dart';

class AssistantMethod {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String st1, st4;
    String placeAddress = "";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      /* Giving the full address can be a privacy risk for the user so we retrieve the address components step by step to avoid privacy invasion
      placeAddress = response["results"][0][
          "formatted_address"]; //Getting the formatted address from the decoded jSon data*/
      //st1 = response["results"][0]["address_components"][0]["long_name"];//House no./FLat no./Office number
      //Private info in above line which we do not want to share!
      //st1 = response["results"][0]["address_components"][1]["long_name"]; //Street Address
      st1 = response["results"][0]["address_components"][3]["long_name"];
      // st2 = response["results"][0]["address_components"][4]["long_name"];
      // st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = st1 + "," + st4;
      Address userPickupAddress = Address();
      userPickupAddress.latitude = position.latitude;
      userPickupAddress.longitude = position.longitude;
      userPickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickupLocationAddress(
          userPickupAddress); //Updating the address

    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainDirection(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionURL =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
    var res = await RequestAssistant.getRequest(directionURL);
    if (res == "failed") {
      return DirectionDetails();
    }
    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];

    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];

    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static double calculateFare(DirectionDetails directionDetails) {
    int ratePerminute = 2;
    int ratePerKM = 10;
    double timeTravelledFare =
        (directionDetails.durationValue / 60) * ratePerminute;
    double distanceTravelledFare =
        (directionDetails.distanceValue / 1000) * ratePerKM;
    double totalFare = timeTravelledFare + distanceTravelledFare;
    return totalFare;
  }

  static void getOnlineUserInfo() async {
    user = await FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapshot);
      }
    });
  }
}
