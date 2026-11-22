import '../data/seed_products.dart';
import '../models/product.dart';

/// Base exception for catalog repository operations.
class CatalogException implements Exception {
  final String message;
  const CatalogException(this.message);

  @override
  String toString() => 'CatalogException: $message';
}

/// Thrown when a targeted product cannot be found in the catalog.
class ProductNotFoundException extends CatalogException {
  final String productId;
  const ProductNotFoundException(this.productId)
      : super('Product not found with ID: $productId');
}

/// Abstract contract for catalog persistence and retrieval.
/// Implementations can back this with In-Memory storage, Firebase Cloud Firestore,
/// or a remote REST API without modifying the consumer presentation layer.
abstract class CatalogRepository {
  /// Fetches all products currently in the catalog.
  Future<List<Product>> getProducts();

  /// Retrieves a specific product by its unique [id], or null if absent.
  Future<Product?> getProductById(String id);

  /// Inserts a new [product] into the catalog.
  Future<void> addProduct(Product product);

  /// Updates an existing [product] in the catalog.
  Future<void> updateProduct(Product product);

  /// Deletes a product with the given [id] from the catalog.
  Future<void> deleteProduct(String id);

  /// Toggles the in-stock availability flag of a product with the given [id].
  Future<void> toggleAvailability(String id);
}

/// A fully functional In-Memory implementation of [CatalogRepository]
/// preloaded with Wakshe Agrotech's handcrafted tool seed items.
class InMemoryCatalogRepository implements CatalogRepository {
  final List<Product> _products;
  final Duration simulatedDelay;

  InMemoryCatalogRepository({
    List<Product>? seedProducts,
    this.simulatedDelay = Duration.zero,
  }) : _products = seedProducts != null
            ? List<Product>.from(seedProducts)
            : List<Product>.from(initialSeedProducts);

  Future<void> _simulateNetwork() async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    await _simulateNetwork();
    // Return a defensive copy to prevent external mutation
    return List<Product>.unmodifiable(_products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    await _simulateNetwork();
    try {
      return _products.firstWhere((p) => p.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    await _simulateNetwork();
    final existingIndex = _products.indexWhere((p) => p.id == product.id);
    if (existingIndex != -1) {
      throw CatalogException(
          'Product with ID "${product.id}" already exists.');
    }
    _products.insert(0, product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _simulateNetwork();
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      throw ProductNotFoundException(product.id);
    }
    _products[index] = product.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _simulateNetwork();
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> toggleAvailability(String id) async {
    await _simulateNetwork();
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw ProductNotFoundException(id);
    }
    final current = _products[index];
    _products[index] = current.copyWith(
      stock: current.stock > 0 ? 0 : 10,
      updatedAt: DateTime.now(),
    );
  }
}
