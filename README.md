# TourPool

A car pool/rental app targeted for Tourists using Flutter and Firebase.Both tourist and driver side (In Progress) apps which will provide the login/signup and simulate hiring a car using Firebase,and maps from GCP APIs,Also determining nearest drivers and automating the connection for the same with price determination and payment simulation.The business motivation behind this app is the insight about how tourists are often charged absurd prices for the car rentals in difficult terrains where no ride hailing apps offer any alternatives.So,This app means to connect the locals to offer pooling services and make money simultaneously making travel cheap for some tourists.

Live Demo of Tourist side app : https://youtu.be/auksNArJgr4


Tourist App

In lib create DifferentScreens Package which would contain the code for all the individual screens!

 home_screen.dart 
Will contain the first screen that you land on
And we will remove the debug banner 
MyApp would return const HomeScreen()



Connect to firebase
Select right package name
And then attach the app 
Download google-services.json to the app folder
And then add the firebase SDK to the android folder build.gradle 
pubspec.yaml file

Connecting and adding the Realtime Database and adding the dependencies to the pubspec.yaml file
Firebase core
Firebase database
And Firebase auth


Add fonts/images/icons
And then proceed to creating a new dart file in the different screens package which will be the login page


Design the login page
Obscure text=true means that the dotted password type is enabled

Single child scroll view because screen size can be really small and then it shouldn’t not show the entire thing That’s why scroll functionality should be enabled!


After adding the idscreen string in each screen
We added the initial route to the login page and then also added navigators to each of the pages like register and log-in from each other!

Next to add functionality to the login and sign up pages we need TextEditingControllers
Using the texteditingControllers we can add the functionality and connect the TextFields to the db and we add controller in each of the textfields with the same name as the texteditingcontrollers


On clicking the Sign-Up button we have to write a function RegisterNewUser(context)
And we will pass the context to it 

FirebaseUser changed to User
And we create an instance of firebaseAuth and then we put checks of the name length and print errors By generating a flutter toast everytime there is some sort of error like that


Firebase authentication and log-in successfully implemented
We are checking whether the datasnapshot is null which means that the data doesn’t exist in the server for them


Then we add a dialogue box for the progress thing

We create a new package for all the different widgets!

Navigate pop for progress dialog
It will have a message as a constructor we will pass the message for the progressDialog
From the login as well as the registration screens
Both work fabulously!


Now we will proceed to add google maps to our application and track the user current live location!

Using google cloud platform APIs and services we have to enable the Maps for android SDK and Maps for iOS SDK
Copy API key from the credentials!

Adding the meta data to the AndroidManifest.xml and AppDelegate.swift file and along with the API key create a new dart file configure_maps to store the API key as a string!

Then we add the Stack after the appbar in the Mainscreenand within that we will be adding the googleMap and then googlePlex location is taken as the initial location

Now we can see the map after loggin in and reaching the Home screen


Next We will add the Home address saving functionality!!
After creating the containers with the icons for Home and work


We can proceed to adding the navigation drawer through which we’ll add a stack symbol
And that can be used to open a profile page or see an overlay with the profile options

Successfully added a menu option that is basically a drawer for this we needed to create the buttons and we create a global scaffold key that we basically embed inside the ontap of the gesture detector !

Next we’ll move to getting the current location of the user!
For this we will use the geolocator package
We’ll write a void locateposition function that would assign the current location from the Geolocator to the currentLocation variable
Within it we create a LatLng varibale to store the latitude and longitude of the position
So Now we need to move the camera according to the current position that we have obtained
So we’ll create a variable of the cameraposition type
And in the constructor we will pass the target latlng variable we just created and the Zoom level we require say 14
Then we’ll use a newGoogleMapController and use it’s animate camera feature By passing the cameraUpdate.newCameraposition with the camera position we obtained
And then we will embed this function inside the onMap Created instance

Now one important thing about this app is that whenever it wants to grab the location it needs to ask the user for that permission for the app  ,So,For that we have to follow the documentationand make modifications in the androidManifest.xml file and related iOS files as well.


Location permission not working yet

Manually allowed location permissions for the app
And now it’s working!


Next we will use geocoding and reverse geocoding to turn the latitude longitude to human readable addresses and reverse

For this API to work we need to enable billing for GCP
So we’ll take a pass on this till Dad comes back and I can ask for his credit card







You need to create a maps billing account otherwise it won’t work 
Because it needs the currency type to be in USD for it to work!

Now we can simply interconvert Geolocation to human readable forms and reverse!



Now we will add HTTP dependency so our application can make POST and GET requests

We’ll create a new package for assisting us to use  the geocoding and the reverse geocoding and we will parse the json format data to get the following

For any coordinates we will receive the formatted address from the json data 
Now whenever we get the current location
We can easily also get the human readable form in the run analysis/log


Next we will create a new package data_handler implement the data provider class
We’ll use the provider package
And we’ll create an app_data dart file


Then we will create a new package called Models
And create address.dart


Also displaying the entire formatted address is a privacy risk so we would like to remove the apt number or sth to make the address close to the home address but not exactly that so that that privacy is maintained and the driver cannot see that!

Finally we can display the current address in place of the Home address!
Next we’ll add Search and create destination functions to the buttons we previously designed!

Now we’ll work on the search thing
We’ll wrap the container containing the Find drop off point text with a GestureDetector and then we will send it to the Search Screen

Finally we added the search screen with boxes that have textfields and attached texteditingcontrollers to them 
And we auto receive the pickup location from the user location!



Next we’ll enable the google places API to add the autocomplete feature to the app!





Next this places api helps us use an autocomplete feature in the text field!

Places receives all the predictions from words but it is not country specific!

 We add &component=country:in For India at the end of our url to get the country specific recommendations!

Now we are able to get these in our Dart Analysis window but we need to show it on display So Let’s do that!

We were able to display a List tile of recommendations of locations that dynamically change by typing in the text box 
So next we need to make all these list elements clickable
Which is by wrapping the Container that we were returning with a Flat button widget!
Next we’ll get the place details (LatLng coordinates)
Then we’ll write a new function called in the PredictionTile class
Called getPlaceAddressDetails
 And within it we will receive the entire response in the json format and then we can individually assign the lat lng and placeID to the address and it’s components


Now the buttons are functioning properly!

Next we need to provide the line joining the map from pickup to drop Off
Using the google direction API
Enable it in the cloud console
So we will create a new obtainDirections method in the assistant_methods file

Next we will draw Polyline in the map for connecting the pickup and drop off locations!

We install the flutter polyline point dependency!
Which we’ll use to draw on the map
Next we will add the markers at the pickup and drop off locations and then create their sets to colour all the coordinates in the markers
And also provide the reverse geocoding for those locations

Next we will design the ride Fare estimates!

And we will be adding a switching functionality between the two containers
The search container and the ride price details container!
We will open the Mainscreen with TickerProviderStateMixin
We will write a function that will display the ride details container
Basically we will await the getPlaceDirection function and as soon as we receive that we will hide the previous search container and display the new one with the ride estimates

And then we will wrap the container containing the search screen with AnimatedSize widget with curved animated to smoothen the transition

Next we will write our functions to calculate ride fare and duration using the journey distance ! (Not realistic but should work for simple paths)




Then finally we will write a reset function to reset the app to it’s primary state when current journey isnt selected we will reset all the values to initial
And we will convert the menu stack icon to a cross icon
Next we created a small animation container to display when the request ride button is clicked
Now we will connect the ride features to the backend
So we can simulate requesting and cancelling a ride!
Basically we will save/remove the user ride request information to the firebase database!
Do all the modifications and writ ethe relevant functions to push the data to the realtime data base
And
In the firebase console we have to change the rules for read and write to true
We successfully connected the database to the user auth as well the ride details and info 
And it also removes in real time from the database using the cancel ride button which appears while requesting a ride


So,To avoid people from loggin in everytime they open the app
We can simply add a Firebase Auth check at the initial route!

And now we need to implement the sign out feature!
We’ll add one more list tile in the ListTile of the drawer!


Now I’ll post the tourist side app on github along with a demo video
