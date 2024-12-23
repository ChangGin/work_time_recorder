import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:work_time_recorder/permission_handler.dart';


final geoProvider = AsyncNotifierProvider<GeoNotifier, Geo>(GeoNotifier.new);

@immutable
class Geo {
  final bool hasPermission;
  final Position position;
  final Placemark place;
  final bool initialized;
  const Geo({
    required this.hasPermission,
    required this.position,
    required this.place,
    required this.initialized,
  });
  Geo copyWith({bool? hasPermission, Position? position, Placemark? place, bool? initialized}){
    return Geo(hasPermission: hasPermission ?? this.hasPermission, position: position ?? this.position, place: place ?? this.place, initialized: initialized ?? this.initialized);
  }
}

class GeoNotifier extends AsyncNotifier<Geo> {
  @override
  Future<Geo> build() {
    return initialize();
  }
  Future<Geo> initialize() async {
    print("initialize()");
    final _hasPermission = await LocationPermissionsHandler().checkPermission();
    final _position = await Geolocator.getCurrentPosition();
    final _places = await placemarkFromCoordinates(_position.latitude, _position.longitude);
    final _place = _places.first;
    return Geo(hasPermission: _hasPermission, position: _position, place: _place, initialized: true);
  }
  Future updateState(Geo _geo) async {// stateの更新
    print("updateState()");
    await update((data){
      final newState = _geo;
      return newState;
    });
  }
  Future getGeoPosition() async {
    print("getGeoPosition()");
    final _position = await Geolocator.getCurrentPosition();
    final _places = await placemarkFromCoordinates(_position.latitude, _position.longitude);
    final _place = _places.first;
    final _newGeo = state.value!.copyWith(position: _position, place: _place);
    updateState(_newGeo);
  }
  permissionUpdate(bool _isPermission) {
    final _newGeo = state.value!.copyWith(hasPermission: _isPermission);
    updateState(_newGeo);
  }
}