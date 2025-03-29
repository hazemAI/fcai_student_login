import 'package:fcai_student_login/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/store.dart';

class StoreProvider with ChangeNotifier {
  List<Store> _stores = [];
  List<String> _favoriteStoreIds = [];
  Position? _currentPosition;
  bool _isLoading = false;

  StoreProvider() {
    _initStores();
  }

  List<Store> get stores => _stores;
  List<Store> get favoriteStores =>
      _stores.where((store) => _favoriteStoreIds.contains(store.id)).toList();
  bool get isLoading => _isLoading;
  Position? get currentPosition => _currentPosition;

  Future<void> _initStores() async {
    _isLoading = true;
    notifyListeners();

    try {
      var box = await Hive.openBox<Store>('stores');

      if (box.isEmpty) {
        await box.addAll([
          Store(
            id: '1',
            name: 'Grocery Store',
            imageUrl: 'assets/images/grocery.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
          ),
          Store(
            id: '2',
            name: 'Electronics Shop',
            imageUrl: 'assets/images/electronics.jpg',
            latitude: 37.7833,
            longitude: -122.4167,
          ),
          Store(
            id: '3',
            name: 'Fashion Outlet',
            imageUrl: 'assets/images/fashion.jpg',
            latitude: 37.7694,
            longitude: -122.4862,
          ),
          Store(
            id: '4',
            name: 'Bookstore',
            imageUrl: 'assets/images/books.jpg',
            latitude: 37.7841,
            longitude: -122.4069,
          ),
          Store(
            id: '5',
            name: 'Coffee Shop',
            imageUrl: 'assets/images/coffee.jpg',
            latitude: 37.7899,
            longitude: -122.4000,
          ),
        ]);
      }

      _stores = box.values.toList();
      await refreshLocation();
    } catch (e) {
      print('Error initializing stores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites(BuildContext context) async {
    var userEmail = context.read<UserProvider>().emailLogin;
    print(userEmail);

    try {
      var box = await Hive.openBox<List<dynamic>>('favorites');
      List<dynamic>? favoriteIds = box.get(userEmail);

      if (favoriteIds != null) {
        _favoriteStoreIds = favoriteIds.map((id) => id.toString()).toList();
      } else {
        _favoriteStoreIds = [];
      }

      notifyListeners();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(String storeId, BuildContext context) async {
    var userEmail = context.read<UserProvider>().emailLogin;

    if (_favoriteStoreIds.contains(storeId)) {
      _favoriteStoreIds.remove(storeId);
    } else {
      _favoriteStoreIds.add(storeId);
    }

    try {
      var box = await Hive.openBox<List<dynamic>>('favorites');
      await box.put(userEmail!, _favoriteStoreIds);
    } catch (e) {
      print('Error saving favorites: $e');
    }

    notifyListeners();
  }

  bool isFavorite(String storeId) {
    return _favoriteStoreIds.contains(storeId);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _currentPosition = await Geolocator.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  double calculateDistance(Store store) {
    if (_currentPosition == null) return -1;

    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          store.latitude,
          store.longitude,
        ) /
        1000;
  }

  Future<void> refreshLocation() async {
    await _determinePosition();
  }

  void refresh(){
    _favoriteStoreIds = [];
    _isLoading = false;
    _currentPosition = null;
    notifyListeners();
  }
}
