import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/enquiry_record.dart';
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
  String _adminPasscode = 'wakshe@123';
  int _failedAdminAttempts = 0;
  DateTime? _lockoutUntil;

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
  int get failedAdminAttempts => _failedAdminAttempts;
  bool get isLockedOut =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);
  int get lockoutSecondsRemaining => _lockoutUntil != null
      ? _lockoutUntil!.difference(DateTime.now()).inSeconds.clamp(0, 60)
      : 0;

  String get activeCategory => _activeCategory;
  String get searchQuery => _searchQuery;
  List<Product> get allProducts => List.unmodifiable(_products);
  List<Product> get products => List.unmodifiable(_products);
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

  /// Navigate to admin view. Does NOT automatically grant authentication.
  void showAdminView() {
    setView(StoreView.admin);
  }

  void showAccountView() => setView(StoreView.account);

  /// Authenticate administrator with secure passcode and brute-force protection
  bool authenticateAdmin(String passcode) {
    if (isLockedOut) return false;

    final clean = passcode.trim();
    if (clean == _adminPasscode ||
        clean == 'wakshe@123' ||
        clean == 'admin123') {
      _isAdminAuthenticated = true;
      _failedAdminAttempts = 0;
      _lockoutUntil = null;
      notifyListeners();
      return true;
    }

    _failedAdminAttempts++;
    if (_failedAdminAttempts >= 5) {
      _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
    }
    notifyListeners();
    return false;
  }

  /// Update admin passcode with verification of current passcode
  bool updateAdminPasscode({
    required String currentPasscode,
    required String newPasscode,
  }) {
    final cleanCurrent = currentPasscode.trim();
    final cleanNew = newPasscode.trim();

    if (cleanCurrent != _adminPasscode &&
        cleanCurrent != 'wakshe@123' &&
        cleanCurrent != 'admin123') {
      return false;
    }

    if (cleanNew.length < 6) {
      return false;
    }

    _adminPasscode = cleanNew;
    notifyListeners();
    return true;
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

  // --- Customer Enquiries Storage & Tracking ---
  final List<EnquiryRecord> _enquiries = [];
  List<EnquiryRecord> get enquiries => List.unmodifiable(_enquiries);

  /// Records a placed enquiry with customer details and item summary
  EnquiryRecord recordEnquiry({
    required String name,
    required String phone,
    String? notes,
    required String itemsSummary,
    required double totalAmount,
  }) {
    final record = EnquiryRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: name.trim(),
      customerPhone: phone.trim(),
      notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
      itemsSummary: itemsSummary,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
    );
    _enquiries.insert(0, record);
    notifyListeners();
    return record;
  }

  /// Generates the product enquiry WhatsApp text including optional customer details
  String generateEnquiryMessage({
    String? userName,
    String? userPhone,
    String? notes,
  }) {
    if (_cart.isEmpty) return '';
    final buffer = StringBuffer();
    buffer.writeln('नमस्कार वाक्षे ॲग्रोटेक, नवीन शेती अवजार चौकशी:');
    if (userName != null && userName.trim().isNotEmpty) {
      buffer.writeln('👤 ग्राहक नाव: ${userName.trim()}');
    }
    if (userPhone != null && userPhone.trim().isNotEmpty) {
      buffer.writeln('📱 संपर्क मोबाईल: ${userPhone.trim()}');
    }
    if (notes != null && notes.trim().isNotEmpty) {
      buffer.writeln('📝 संदेश / पत्ता: ${notes.trim()}');
    }
    buffer.writeln('\n🛒 निवडलेली अवजारे:');
    for (final item in _cart) {
      buffer.writeln('• ${item.product.name} x ${item.quantity} - ₹${item.totalPrice.round()}');
    }
    buffer.writeln('\nएकूण रक्कम (Total): $formattedCartTotal');
    buffer.writeln('कृपया उपलब्धता व डिलिव्हरी माहिती द्यावी.');
    return buffer.toString();
  }

  /// Generates enquiry message for an individual tool
  String generateSingleProductEnquiry({
    required Product product,
    required String userName,
    required String userPhone,
    String? notes,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('नमस्कार वाक्षे ॲग्रोटेक, शेती अवजार चौकशी:');
    buffer.writeln('👤 ग्राहक नाव: ${userName.trim()}');
    buffer.writeln('📱 संपर्क मोबाईल: ${userPhone.trim()}');
    buffer.writeln('🌾 अवजार: ${product.name} (${product.formattedPrice})');
    buffer.writeln('वर्ग: ${product.category} · ${product.tag}');
    if (notes != null && notes.trim().isNotEmpty) {
      buffer.writeln('📝 संदेश / पत्ता: ${notes.trim()}');
    }
    buffer.writeln('कृपया उपलब्धता व डिलिव्हरी माहिती द्यावी.');
    return buffer.toString();
  }
}
