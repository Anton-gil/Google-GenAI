// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Product> products = const [
    Product(
      id: "1",
      name: "Handmade Vase",
      description: "Beautiful ceramic vase with unique design",
      imageUrl: "https://picsum.photos/200/300?1",
    ),
    Product(
      id: "2",
      name: "Wool Scarf",
      description: "Warm and cozy scarf for winter",
      imageUrl: "https://picsum.photos/200/300?2",
    ),
    Product(
      id: "3",
      name: "Leather Wallet",
      description: "Durable handmade leather wallet",
      imageUrl: "https://picsum.photos/200/300?3",
    ),
    Product(
      id: "4",
      name: "Wooden Bowl",
      description: "Eco-friendly handmade wooden bowl",
      imageUrl: "https://picsum.photos/200/300?4",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artisan Marketplace")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (ctx, i) => ProductCard(product: products[i]),
      ),
    );
  }
}
