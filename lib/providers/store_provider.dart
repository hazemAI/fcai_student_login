import 'package:fcai_student_login/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
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
            name: 'Dahab Market',
            imageUrl: 'assets/images/dahab_market.jpg',
            latitude: 31.2198264,
            longitude: 30.0667105,
          ),
          Store(
            id: '2',
            name: 'BIM',
            imageUrl: 'assets/images/bim.png',
            latitude: 31.2240134,
            longitude: 30.0118657,
          ),
          Store(
            id: '3',
            name: 'Shea Egypt',
            imageUrl: 'assets/images/shea_egypt.png',
            latitude: 31.2222855,
            longitude: 30.061007,
          ),
          Store(
            id: '4',
            name: 'Syrian Food Products',
            imageUrl: 'assets/images/syrian_food_products.jpg',
            latitude: 31.2205024,
            longitude: 30.0639556,
          ),
          Store(
            id: '5',
            name: 'Moon Yard Mall',
            imageUrl: 'assets/images/moon_yard_mall.png',
            latitude: 31.6401449,
            longitude: 30.1639161,
          ),
          Store(
            id: '6',
            name: 'Beta Bookshop',
            imageUrl: 'assets/images/beta_bookshop.jpg',
            latitude: 31.2633988,
            longitude: 29.9536339,
          ),
          Store(
            id: '7',
            name: 'Butterfly',
            imageUrl: 'assets/images/butterfly.png',
            latitude: 31.2763169,
            longitude: 29.9577477,
          ),

          Store(
            id: '9',
            name: 'Sindiana',
            imageUrl: 'assets/images/sindiana.jpg',
            latitude: 31.2688468,
            longitude: 29.9508832,
          ),

          Store(
            id: '10',
            name:
                "Theodor's - Antique, vintages, contemporary furniture and beautiful things",
            imageUrl:
                'assets/images/theodor_antique.jpg',
            latitude: 31.2702669,
            longitude: 29.9519826,
          ),

          Store(
            id: '11',
            name: 'Green House',
            imageUrl: 'assets/images/green_house.jpg',
            latitude: 31.2677628,
            longitude: 29.9563596,
          ),

          Store(
            id: '12',
            name: 'Art\'s House For Antiques And Caucasian Carpets',
            imageUrl:
                'assets/images/art_house.jpg',
            latitude: 31.2642814,
            longitude: 29.952464,
          ),

          Store(
            id: '13',
            name: 'Elsayad Bakery',
            imageUrl: 'assets/images/elsayad_bakery.jpg',
            latitude: 31.2642341,
            longitude: 29.9525363,
          ),
          Store(
            id: '14',
            name: 'Lady Land (Said Tailor)',
            imageUrl: 'assets/images/lady_land.jpg',
            latitude: 31.2643838,
            longitude: 29.9524186,
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
      await box.put(userEmail, _favoriteStoreIds);
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

  void openGoogleMapWithDestination(double lat, double lng) async {
    try {
      final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps.';
      }
    } catch (e) {
      print('Error opening Google Maps: $e');
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

  void refresh() {
    _favoriteStoreIds = [];
    _isLoading = false;
    _currentPosition = null;
    notifyListeners();
  }
}
