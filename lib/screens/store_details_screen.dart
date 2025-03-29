import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store.dart';

class StoreDetailsScreen extends StatelessWidget {
  final String storeId;
  
  const StoreDetailsScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (ctx, storeProvider, child) {
        Store? store = storeProvider.stores.firstWhere(
          (store) => store.id == storeId,
          orElse: () => null as Store, // This will throw if store not found
        );
        
        if (store == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Store Details')),
            body: Center(child: Text('Store not found')),
          );
        }
        
        double distance = storeProvider.calculateDistance(store);
        bool isFavorite = storeProvider.isFavorite(store.id);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(store.name),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  storeProvider.toggleFavorite(store.id);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'store-image-${store.id}',
                  child: Image.asset(
                    store.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    distance >= 0
                                        ? '${distance.toStringAsFixed(1)} km away'
                                        : 'Distance unavailable',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.map, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Coordinates: ${store.latitude.toStringAsFixed(4)}, ${store.longitude.toStringAsFixed(4)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        label: Text(
                          isFavorite
                              ? 'Remove from Favorites'
                              : 'Add to Favorites',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFavorite ? Colors.red : Colors.blue,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          storeProvider.toggleFavorite(store.id);
                        },
                      ),
                      SizedBox(height: 16),
                      if (distance < 0)
                        ElevatedButton.icon(
                          icon: Icon(Icons.refresh),
                          label: Text('Refresh Location'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            storeProvider.refreshLocation();
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 