import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/catalog_repository.dart';

enum StoreView { shop, admin, account }

/// State management provider matching the Wakshe Agrotech web store behavior.
class CatalogProvider extends ChangeNotifier {
  final CatalogRepository repository;

  CatalogProvider({required this.repository}) {
    loadCatalog();
  }

  // --- Views & Filters ---
  StoreView _currentView = StoreView.shop;
  String _activeCategory = 'All';
  String _searchQuery = '';
  bool _isAdminAuthenticated = false;

  // --- Catalog & Cart State ---
  List<Product> _products = [];
  final List<CartItem> _cart = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  StoreView get currentView => _currentView;
  bool get isShopView => _currentView == StoreView.shop;
  bool get isAdminView => _currentView == StoreView.admin;
  bool get isAccountView => _currentView == StoreView.account;
  bool get isAdminAuthenticated => _isAdminAuthenticated;

  String get activeCategory => _activeCategory;
  String get searchQuery => _searchQuery;
  List<Product> get allProducts => List.unmodifiable(_products);
  List<CartItem> get cart => List.unmodifiable(_cart);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Total count of items currently in cart
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  /// Total price amount in cart
  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Formatted cart total in INR
  String get formattedCartTotal => '₹${cartTotal.round()}';

  /// Standard filter categories
  List<String> get categories => Product.categories;

  /// Filtered product list matching active category & search keyword
  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory =
          _activeCategory == 'All' || product.category == _activeCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;
      final fullText =
          '${product.name} ${product.category} ${product.description}'
              .toLowerCase();
      return fullText.contains(query);
    }).toList();
  }

  // --- View & Navigation Actions ---

  void setView(StoreView view) {
    if (_currentView != view) {
      _currentView = view;
      notifyListeners();
    }
  }

  void showShopView() => setView(StoreView.shop);

  void showAdminView() {
    _isAdminAuthenticated = true;
    setView(StoreView.admin);
  }

  void showAccountView() => setView(StoreView.account);

  /// Authenticate administrator with passcode (default demo: admin123)
  bool authenticateAdmin(String passcode) {
    final clean = passcode.trim();
    if (clean == 'admin123' || clean == 'admin' || clean == '1234') {
      _isAdminAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Lock administrator session and return to shop if on admin screen
  void logoutAdmin() {
    _isAdminAuthenticated = false;
    if (_currentView == StoreView.admin) {
      _currentView = StoreView.shop;
    }
    notifyListeners();
  }

  void setCategory(String category) {
    if (_activeCategory != category) {
      _activeCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _activeCategory = 'All';
    notifyListeners();
  }

  // --- Catalog CRUD Actions ---

  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await repository.getProducts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading catalog: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      await repository.addProduct(product);
      await loadCatalog();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editProduct(Product product) async {
    try {
      await repository.updateProduct(product);
      await loadCatalog();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await repository.deleteProduct(id);
      await loadCatalog();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      notifyListeners();
      return false;
    }
  }

  // --- Shopping Cart Actions ---

  /// Adds a product to cart. Returns true on success, false if out of stock.
  bool addToCart(Product product) {
    if (product.stock <= 0) return false;

    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cart[index].quantity += 1;
    } else {
      _cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
    return true;
  }

  void updateCartQuantity(String productId, int quantity) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Generates the product enquiry WhatsApp text as defined in the HTML demo
  String generateEnquiryMessage() {
    if (_cart.isEmpty) return '';
    final lines = _cart
        .map((item) =>
            '${item.product.name} x ${item.quantity} - ₹${item.totalPrice.round()}')
        .join('\n');
    return 'Hello Wakshe Agrotech, I would like to enquire about:\n$lines\nTotal: $formattedCartTotal';
  }
}
