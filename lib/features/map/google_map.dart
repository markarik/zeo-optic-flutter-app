import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ze_optic_tech/imports.dart';
import 'package:ze_optic_tech/keys.dart';

class UserCurrentLocation extends StatefulWidget {
  const UserCurrentLocation({super.key, required this.userId});
  final String userId;

  @override
  UserCurrentLocationState createState() => UserCurrentLocationState();
}

class UserCurrentLocationState extends State<UserCurrentLocation> {
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();

  LatLng? _center;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DatabaseEvent>? _locationSubscription;
  LatLng? _selectedUserLocation;

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  String googleAPiKey = google_maps_key;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _listenToLocationChanges();
  }

  void _listenToLocationChanges() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) async {
      await _saveLocationToFirebase(position);

          _listenToUserLocation(widget.userId);


      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });

      _controller.future.then((mapController) {
        mapController.animateCamera(CameraUpdate.newLatLng(_center!));
      });
    });
  }

  Future<void> _saveLocationToFirebase(Position position) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _dbRef.child('users/${user.uid}/location').set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Function to listen to the selected user's location
  void _listenToUserLocation(String userId) {
    _locationSubscription?.cancel();

    _locationSubscription = _dbRef
        .child('users/$userId/location')
        .onValue
        .listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final double latitude = data['latitude'];
        final double longitude = data['longitude'];
        _selectedUserLocation = LatLng(latitude, longitude);
        drawPath();

        _controller.future.then((mapController) {
          mapController
              .animateCamera(CameraUpdate.newLatLng(_selectedUserLocation!));
        });

        setState(() {});
      }
    });
  }

  // Function to create markers on the map
  Set<Marker> _createMarkers() {
    final markers = <Marker>{};

    // Marker for your current location
    markers.add(Marker(
      markerId: const MarkerId('currentLocation'),
      position: _center!,
      infoWindow: const InfoWindow(title: 'Your Location'),
    ));

    // Marker for the selected user's location
    if (_selectedUserLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('selectedUser'),
        position: _selectedUserLocation!,
        infoWindow: const InfoWindow(title: 'Selected User'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    return markers;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationSubscription?.cancel();

    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }
    _currentPosition = await Geolocator.getCurrentPosition();
    await _saveLocationToFirebase(_currentPosition!);

    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    });
  }

  drawPath() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPiKey,
      request: PolylineRequest(
        origin: PointLatLng(_center!.latitude, _center!.longitude),
        destination: PointLatLng(
            _selectedUserLocation!.latitude, _selectedUserLocation!.longitude),
        mode: TravelMode.driving,
        optimizeWaypoints: true,
        // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      log("result.errorMessage ${result.errorMessage}");
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Location Map'),
      ),
      body: _center == null
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              height: double.infinity,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center!,
                  zoom: 15.0,
                ),
                markers:
                    _createMarkers(), // Add markers for your location and selected user
                myLocationEnabled: true, // Show the current user location
                polylines: Set<Polyline>.of(polylines.values), //polylines
              ),
            ),
    );
  }
}
