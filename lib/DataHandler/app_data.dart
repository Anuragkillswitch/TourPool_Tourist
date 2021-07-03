import 'package:flutter/cupertino.dart';
import 'package:tourist_app/Models/address.dart';

class AppData extends ChangeNotifier {
  Address pickupLocation = Address();
  Address dropOffLocation = Address();

  void updatePickupLocationAddress(Address pickupAddress) {
    pickupLocation = pickupAddress;
    notifyListeners(); //Broadcasting the changes
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners(); //Broadcasting the changes
  }
}
