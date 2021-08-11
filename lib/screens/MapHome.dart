import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/directions/directions.dart';
import 'package:google_map/repository/direction_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:url_launcher/url_launcher.dart';

const String apiKey = 'AIzaSyCJwiyOTIRzetEjeXFJvdAl_NtFwzOyglI';

class MapScreen extends StatefulWidget {
  // Position position;
  // MapScreen(this.position);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = Set();
  LatLng? sourceLatLong;

  final LatLng destinationLatLong = LatLng(12.9716, 77.5946);
  GoogleMapController? _googleMapController;
  Directions? _info;
   Location location = new Location();
  bool isLoading=true;

  @override
  void initState() {
 // getLocation().then((value){
 //   setState(() {
 //     sourceLatLong = LatLng(value.latitude!, value.longitude!);
 //     isLoading=false;
 //     print("LocationData"+ value.longitude.toString());
 //   });
 //   Future.delayed(Duration(seconds: 1), () async {
 //     _addMarker();
 //     final directions = await DirectionsRepository().getDirections(
 //         origin: LatLng(value.latitude!, value.longitude!),
 //         destination: destinationLatLong);
 //     setState(() {
 //       _info = directions;
 //     });
 //
 //   });
 // });
    Timer(Duration(seconds: 3),(){
      manageLocationPermission().then((value) {
        setState(() {
          sourceLatLong = LatLng(value.latitude!, value.longitude!);
          isLoading=false;
        });
        Future.delayed(Duration(seconds: 1), () async {
          final directions = await DirectionsRepository().getDirections(
              origin: LatLng(value.latitude!, value.longitude!),
              destination: destinationLatLong);
          setState(() {
            _info = directions;
          });
          _addMarker();
        });
      });
    });


    super.initState();
  }

  Future<LocationData> getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {}
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {}
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }
  Future<LocationData> manageLocationPermission() async {
    LocationData locationData;
    final Location location = Location();
    // bool serviceEnabled;
    // PermissionStatus permissionGranted;
    //
    // serviceEnabled = await location.serviceEnabled();
    // if (!serviceEnabled) {
    //   serviceEnabled = await location.requestService();
    //   if (!serviceEnabled) {
    //     return Future.error('Location services are disabled.');
    //   }
    // }
    //
    // permissionGranted = await location.hasPermission();
    // if (permissionGranted == PermissionStatus.denied) {
    //   permissionGranted = await location.requestPermission();
    //   //TODO: do your logic to manage when user denies the permission
    //   if (permissionGranted != PermissionStatus.granted) {
    //
    //     return Future.error('Location permissions are denied');
    //   }
    // }
    locationData = await location.getLocation();

    return locationData;
  }
  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   // serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   // if (!serviceEnabled) {
  //   //
  //   //   return Future.error('Location services are disabled.');
  //   // }
  //   //
  //   // permission = await Geolocator.checkPermission();
  //   // if (permission == LocationPermission.denied) {
  //   //   permission = await Geolocator.requestPermission();
  //   //   if (permission == LocationPermission.denied) {
  //   //     return Future.error('Location permissions are denied');
  //   //   }
  //   // }
  //   //
  //   // if (permission == LocationPermission.deniedForever) {
  //   //   // Permissions are denied forever, handle appropriately.
  //   //   return Future.error(
  //   //       'Location permissions are permanently denied, we cannot request permissions.');
  //   // }
  //
  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   return await Geolocator.getCurrentPosition();
  // }

  launchURL() async {
    String googleMapslocationUrl =
        "https://www.google.com/maps/search/?api=1&query=${destinationLatLong.latitude},${destinationLatLong.longitude}";

    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);

    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      print('Could not launch $encodedURl');
      throw 'Could not launch $encodedURl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Google Map'),
      ),
      body: isLoading?Center(child: CircularProgressIndicator(),):Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              target: destinationLatLong,
              zoom: 6.0000,
            ),
            onMapCreated: (controller) async {
              _googleMapController = controller;
            },
            markers: _markers,
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.blue,
                  width: 5,
                  points: _info!.polylinePoints!
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
          ),
          if (_info != null)
            Positioned(
              top: 10.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 60,
            left: 20,
            child: TextButton(
              onPressed: () {
                launchURL();
              },
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.navigation,
                        color: Colors.blue,
                        size: 35,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Navigate",
                        style: TextStyle(color: Colors.black, fontSize: 18))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addMarker() async {
    _markers.add(Marker(
        markerId: MarkerId("1"),
        position: sourceLatLong!,
        infoWindow: InfoWindow(
          title: "source: Ahmedabd",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        visible: true));

    _markers.add(Marker(
      markerId: MarkerId("2"),
      position: destinationLatLong,
      infoWindow: InfoWindow(
        title: "destination: Rajkot",
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
  }
}
