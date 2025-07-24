// Banner model class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../constant/colors.dart';
import 'addBanner.dart';

class Banner {
  final String id;
  final String photoName;
  final String photo;

  Banner({
    required this.id,
    required this.photoName,
    required this.photo,
  });

  factory Banner.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Banner(
      id: doc.id,
      photoName: data['photoName'] ?? '',
      photo: data['photo'] ?? '',
    );
  }
}

// Banner grid widget with Firebase integration
class BannerGrid extends StatefulWidget {
  const BannerGrid({Key? key}) : super(key: key);

  @override
  _BannerGridState createState() => _BannerGridState();
}

class _BannerGridState extends State<BannerGrid> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _bannersStream;

  @override
  void initState() {
    super.initState();
    _bannersStream = _firestore.collection('Banner').snapshots();
  }

  Future<void> _deleteBanner(String docId) async {
    try {
      await _firestore.collection('Banner').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting banner: $e')),
      );
    }
  }

  Future<void> _showDeleteDialog(Banner banner) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Banner'),
          content:
              Text('Are you sure you want to delete "${banner.photoName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBanner(banner.id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _bannersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Banner> banners = snapshot.data!.docs
            .map((doc) => Banner.fromFirestore(doc))
            .toList();

        if (banners.isEmpty) {
          return const Center(child: Text('No banners available'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: banners.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () => _showDeleteDialog(banners[index]),
              child: Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.network(
                        banners[index].photo,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error_outline, size: 40),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        banners[index].photoName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Example usage screen
class BannerScreen extends StatelessWidget {
  const BannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: const Text('Banners'),
      ),
      body: const BannerGrid(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: useColor.homeIconColor,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddBannerDialog(),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
