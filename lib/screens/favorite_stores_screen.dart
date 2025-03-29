import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store.dart';
import 'store_details_screen.dart';

class FavoriteStoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Stores'),
      ),
      body: Consumer<StoreProvider>(
        builder: (ctx, storeProvider, child) {
          final favoriteStores = storeProvider.favoriteStores;
          
          if (favoriteStores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorite stores yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add stores to your favorites to see them here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: favoriteStores.length,
            itemBuilder: (ctx, index) {
              Store store = favoriteStores[index];
              return FavoriteStoreItem(store: store);
            },
          );
        },
      ),
    );
  }
}

class FavoriteStoreItem extends StatelessWidget {
  final Store store;
  
  const FavoriteStoreItem({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(store.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Remove from Favorites'),
            content: Text('Are you sure you want to remove ${store.name} from your favorites?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<StoreProvider>(context, listen: false).toggleFavorite(store.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${store.name} removed from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
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
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () {
                  Provider.of<StoreProvider>(context, listen: false).toggleFavorite(store.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 