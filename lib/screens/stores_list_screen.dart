import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store.dart';
import 'store_details_screen.dart';

class StoresListScreen extends StatelessWidget {
  const StoresListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Stores'),
      ),
      body: Consumer<StoreProvider>(
        builder: (ctx, storeProvider, child) {
          if (storeProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (storeProvider.stores.isEmpty) {
            return Center(child: Text('No stores available'));
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: storeProvider.stores.length,
            itemBuilder: (ctx, index) {
              Store store = storeProvider.stores[index];
              return StoreListItem(store: store);
            },
          );
        },
      ),
    );
  }
}

class StoreListItem extends StatelessWidget {
  final Store store;
  
  const StoreListItem({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => StoreDetailsScreen(storeId: store.id),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
              child: Image.asset(
                store.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Consumer<StoreProvider>(
                      builder: (ctx, storeProvider, child) {
                        double distance = storeProvider.calculateDistance(store);
                        return distance >= 0
                            ? Text('${distance.toStringAsFixed(1)} km away')
                            : Text('Distance unavailable');
                      },
                    ),
                  ],
                ),
              ),
            ),
            Consumer<StoreProvider>(
              builder: (ctx, storeProvider, child) {
                return IconButton(
                  icon: Icon(
                    storeProvider.isFavorite(store.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: storeProvider.isFavorite(store.id)
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () {
                    storeProvider.toggleFavorite(store.id);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 