// Renders every Avero screen on small phones, large phones, landscape phones
// and tablets, at normal and large font sizes, in light and dark mode, and
// fails on any layout overflow or build error. Firebase is replaced by
// in-memory fakes.
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_ecommerce_app/core/theme/app_theme.dart';
import 'package:flutter_ecommerce_app/core/theme/theme_controller.dart';
import 'package:flutter_ecommerce_app/data/models/address_model.dart';
import 'package:flutter_ecommerce_app/data/models/category_model.dart';
import 'package:flutter_ecommerce_app/data/models/order_models.dart';
import 'package:flutter_ecommerce_app/data/models/product_model.dart';
import 'package:flutter_ecommerce_app/data/models/user_model.dart';
import 'package:flutter_ecommerce_app/data/models/vendor_model.dart';
import 'package:flutter_ecommerce_app/data/models/wishlist_item_model.dart';
import 'package:flutter_ecommerce_app/data/repositories/address_repository.dart';
import 'package:flutter_ecommerce_app/data/repositories/auth_repository.dart';
import 'package:flutter_ecommerce_app/data/repositories/cart_repository.dart';
import 'package:flutter_ecommerce_app/data/repositories/order_repository.dart';
import 'package:flutter_ecommerce_app/data/repositories/product_repository.dart';
import 'package:flutter_ecommerce_app/data/repositories/user_repository.dart';
import 'package:flutter_ecommerce_app/data/repositories/vendor_repository.dart';
import 'package:flutter_ecommerce_app/data/repositories/wishlist_repository.dart';
import 'package:flutter_ecommerce_app/data/services/auth_service.dart';
import 'package:flutter_ecommerce_app/data/services/local_product_image_service.dart';
import 'package:flutter_ecommerce_app/data/services/theme_storage_service.dart';
import 'package:flutter_ecommerce_app/modules/app_shell/controller/app_shell_controller.dart';
import 'package:flutter_ecommerce_app/modules/app_shell/view/app_shell_view.dart';
import 'package:flutter_ecommerce_app/modules/auth/forgot_password/controller/forgot_password_controller.dart';
import 'package:flutter_ecommerce_app/modules/auth/forgot_password/view/forgot_password_view.dart';
import 'package:flutter_ecommerce_app/modules/auth/login/controller/login_controller.dart';
import 'package:flutter_ecommerce_app/modules/auth/login/view/login_view.dart';
import 'package:flutter_ecommerce_app/modules/auth/signup/controller/signup_controller.dart';
import 'package:flutter_ecommerce_app/modules/auth/signup/view/signup_view.dart';
import 'package:flutter_ecommerce_app/modules/cart/controller/cart_controller.dart';
import 'package:flutter_ecommerce_app/modules/cart/view/cart_view.dart';
import 'package:flutter_ecommerce_app/modules/checkout/controller/checkout_controller.dart';
import 'package:flutter_ecommerce_app/modules/checkout/view/checkout_view.dart';
import 'package:flutter_ecommerce_app/modules/collection/controller/collection_controller.dart';
import 'package:flutter_ecommerce_app/modules/home/controller/home_controller.dart';
import 'package:flutter_ecommerce_app/modules/product_detail/controller/product_detail_controller.dart';
import 'package:flutter_ecommerce_app/modules/product_detail/view/product_detail_view.dart';
import 'package:flutter_ecommerce_app/modules/profile/controller/profile_controller.dart';
import 'package:flutter_ecommerce_app/modules/splash/view/splash_view.dart';
import 'package:flutter_ecommerce_app/modules/vendor/become_vendor/controller/become_vendor_controller.dart';
import 'package:flutter_ecommerce_app/modules/vendor/become_vendor/view/become_vendor_view.dart';
import 'package:flutter_ecommerce_app/modules/vendor/dashboard/controller/vendor_dashboard_controller.dart';
import 'package:flutter_ecommerce_app/modules/vendor/dashboard/view/vendor_dashboard_view.dart';
import 'package:flutter_ecommerce_app/modules/vendor/orders/controller/vendor_orders_controller.dart';
import 'package:flutter_ecommerce_app/modules/vendor/orders/view/vendor_orders_view.dart';
import 'package:flutter_ecommerce_app/modules/vendor/products/controller/vendor_product_form_controller.dart';
import 'package:flutter_ecommerce_app/modules/vendor/products/controller/vendor_products_controller.dart';
import 'package:flutter_ecommerce_app/modules/vendor/products/view/vendor_product_form_view.dart';
import 'package:flutter_ecommerce_app/modules/vendor/products/view/vendor_products_view.dart';
import 'package:flutter_ecommerce_app/modules/wishlist/controller/wishlist_controller.dart';
import 'package:flutter_ecommerce_app/modules/wishlist/view/wishlist_view.dart';

// ---------------------------------------------------------------------------
// Demo data with deliberately long names and big numbers to stress layouts.
// ---------------------------------------------------------------------------

const _uid = 'vendor-1';

final _categories = [
  for (final name in ['Hoodies', 'Shoes', 'Accessories', 'Bag', 'Shorts'])
    CategoryModel(
      id: name.toLowerCase(),
      name: name,
      isActive: true,
      imageUrl: 'assets/images/demo_catalog/category_bag.png',
    ),
];

final _products = [
  for (var index = 1; index <= 8; index += 1)
    ProductModel(
      id: 'p$index',
      name: index.isEven
          ? "Men's Harrington Jacket With An Extra Long Product Name"
          : 'Nike SB',
      description: 'Lightweight everyday jacket with a clean relaxed fit. ' * 3,
      price: index * 1234.99,
      compareAtPrice: index.isEven ? index * 2000.0 : null,
      imageUrl: 'assets/images/demo_catalog/product_0$index.png',
      categoryId: 'shoes',
      categoryName: 'Shoes',
      vendorId: _uid,
      stock: 12,
      soldCount: 10 - index,
      isActive: index != 3,
    ),
];

const _address = AddressModel(
  id: 'a1',
  fullName: 'Muhammad Saad Hafeez Long Name',
  phone: '+923001234567',
  addressLine1: 'House 123, Street 45, Some Very Long Block Name',
  city: 'Islamabad',
  state: 'Islamabad Capital Territory',
  postalCode: '44000',
  country: 'Pakistan',
  isDefault: true,
);

final _orders = [
  for (var index = 0; index < 3; index += 1)
    OrderModel(
      orderId: 'order$index-abcdefghijk',
      customerId: 'customer-1',
      vendorIds: const [_uid, 'other-vendor'],
      items: const [
        OrderItemSnapshot(
          productId: 'p1',
          vendorId: _uid,
          productName: "Men's Harrington Jacket With An Extra Long Name",
          imageUrl: 'assets/images/demo_catalog/product_01.png',
          quantity: 12,
          unitPrice: 12345.5,
          lineTotal: 148146,
        ),
        OrderItemSnapshot(
          productId: 'x',
          vendorId: 'other-vendor',
          productName: 'Other vendor item',
          quantity: 1,
          unitPrice: 10,
          lineTotal: 10,
        ),
      ],
      subtotal: 148156,
      total: 148156,
      status: 'pending',
      createdAt: DateTime(2026, 10, 1, 18, 5),
    ),
];

// ---------------------------------------------------------------------------
// Fakes: implement the real classes, unused members fall to noSuchMethod.
// ---------------------------------------------------------------------------

class _FakeUser implements User {
  @override
  String get uid => _uid;
  @override
  String? get email => 'saad.hafeez.long.email.address@example.com';
  @override
  String? get displayName => 'Saad Hafeez';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthService implements AuthService {
  @override
  User? get currentUser => _FakeUser();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProductRepository implements ProductRepository {
  @override
  Future<List<CategoryModel>> getActiveCategories() async => _categories;
  @override
  Future<List<ProductModel>> getActiveProducts() async => _products;
  @override
  Future<List<ProductModel>> getActiveProductsByCategory(String id) async =>
      _products;
  @override
  Future<List<ProductModel>> getTopSellingProducts({int? limit}) async =>
      _products;
  @override
  Future<List<ProductModel>> getVendorProducts(String vendorId) async =>
      _products;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCartRepository implements CartRepository {
  @override
  Future<List<CartProductItem>> getCartProductItems(String uid) async => [
    for (final product in _products.take(4))
      CartProductItem(product: product, quantity: 120),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWishlistRepository implements WishlistRepository {
  @override
  Future<List<WishlistItemModel>> getWishlistItems(String uid) async => [
    for (final product in _products) WishlistItemModel(productId: product.id),
  ];
  @override
  Future<List<ProductModel>> getWishlistProducts(String uid) async => _products;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<UserModel> getUserProfile(String uid) async => const UserModel(
    uid: _uid,
    email: 'saad.hafeez.long.email.address@example.com',
    displayName: 'Saad Hafeez With A Long Display Name',
    role: UserModel.vendorRole,
    vendorId: _uid,
    isActive: true,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddressRepository implements AddressRepository {
  @override
  Future<List<AddressModel>> getAddresses(String uid) async => [_address];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrderRepository implements OrderRepository {
  @override
  Future<List<OrderModel>> getVendorOrders(String vendorId) async => _orders;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeVendorRepository implements VendorRepository {
  @override
  Future<VendorModel?> getVendorProfile(String uid) async => VendorModel(
    vendorId: _uid,
    ownerUid: _uid,
    storeName: 'Saad Hafeez Premium Clothing And Accessories Store',
    ownerName: 'Saad',
    email: 'store@example.com',
    phone: '+923001234567',
    description: 'We sell premium hoodies, shoes and bags. ' * 2,
    isActive: true,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestProductDetailController extends ProductDetailController {
  @override
  ProductModel? get product => _products[1];
}

// ---------------------------------------------------------------------------
// Screens under test. Each entry registers its controllers and returns view.
// ---------------------------------------------------------------------------

final _auth = _FakeAuthService();
final _productRepository = _FakeProductRepository();

void _registerShared() {
  Get.put<AuthService>(_auth);
  Get.put(CartController(_FakeCartRepository(), _auth));
  Get.put(WishlistController(_FakeWishlistRepository(), _auth));
}

void _registerShell() {
  _registerShared();
  Get.put(ThemeController(ThemeStorageService()));
  Get.put(AppShellController());
  Get.put(HomeController(_productRepository));
  Get.put(CollectionController(_productRepository));
  Get.put(
    ProfileController(_auth, _FakeAuthRepository(), _FakeUserRepository()),
  );
}

Widget _shellOnTab(int tab, [void Function()? prepare]) {
  _registerShell();
  prepare?.call();
  Get.find<AppShellController>().selectTab(tab);
  return const AppShellView();
}

final Map<String, Widget Function()> _screens = {
  'Splash': () => const SplashView(),
  'Login': () {
    Get.put(LoginController(_FakeAuthRepository(), _auth));
    return const LoginView();
  },
  'Signup': () {
    Get.put(SignupController(_FakeAuthRepository(), _auth));
    return const SignupView();
  },
  'Forgot password': () {
    Get.put(ForgotPasswordController(_FakeAuthRepository()));
    return const ForgotPasswordView();
  },
  'Home tab': () => _shellOnTab(0),
  'Collections tab': () => _shellOnTab(1),
  'Collection products': () => _shellOnTab(1, () {
    Get.find<CollectionController>().selectCategory(_categories[1]);
  }),
  'Top Selling (See All)': () => _shellOnTab(1, () {
    Get.find<CollectionController>().showTopSelling();
  }),
  'Cart tab': () => _shellOnTab(2),
  'Profile tab': () => _shellOnTab(3),
  'Product detail': () {
    _registerShared();
    Get.put<ProductDetailController>(_TestProductDetailController());
    return const ProductDetailView();
  },
  'Wishlist': () {
    _registerShared();
    return const WishlistView();
  },
  'Cart page': () {
    _registerShared();
    return const CartView();
  },
  'Checkout + address form': () {
    _registerShared();
    final controller = Get.put(
      CheckoutController(
        _auth,
        _FakeAddressRepository(),
        _FakeOrderRepository(),
        Get.find<CartController>(),
      ),
    );
    // Open the add-address form (with the phone field) once loaded.
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      controller.showAddressForm.value = true;
    });
    return const CheckoutView();
  },
  'Become a Vendor': () {
    Get.put(BecomeVendorController(_auth, _FakeVendorRepository()));
    return const BecomeVendorView();
  },
  'Vendor dashboard': () {
    Get.put(
      VendorDashboardController(
        _auth,
        _FakeVendorRepository(),
        _productRepository,
        _FakeOrderRepository(),
      ),
    );
    return const VendorDashboardView();
  },
  'Vendor products': () {
    Get.put(
      VendorProductsController(
        _auth,
        _productRepository,
        LocalProductImageService(),
      ),
    );
    return const VendorProductsView();
  },
  'Vendor product form': () {
    Get.put(
      VendorProductFormController(
        _auth,
        _productRepository,
        LocalProductImageService(),
      ),
    );
    return const VendorProductFormView();
  },
  'Vendor orders': () {
    Get.put(VendorOrdersController(_auth, _FakeOrderRepository()));
    return const VendorOrdersView();
  },
};

// Logical sizes: small phone, common phone, large phone, phone landscape,
// tablet portrait, tablet landscape.
const _sizes = <String, Size>{
  '320x568': Size(320, 568),
  '360x800': Size(360, 800),
  '412x915': Size(412, 915),
  '800x360 landscape': Size(800, 360),
  '768x1024 tablet': Size(768, 1024),
  '1280x800 tablet': Size(1280, 800),
};

const _textScales = [1.0, 1.3];

Future<void> _loadRobotoFont() async {
  // Real Roboto metrics instead of the square test font, so text widths
  // match the device.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) {
    return;
  }
  final fontDir = '$flutterRoot/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  for (final file in ['roboto-regular', 'roboto-medium', 'roboto-bold']) {
    final fontFile = File('$fontDir/$file.ttf');
    if (fontFile.existsSync()) {
      final bytes = fontFile.readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
  }
  await loader.load();
}

void main() {
  setUpAll(_loadRobotoFont);

  for (final screen in _screens.entries) {
    testWidgets('${screen.key} has no overflow on any size, font or theme', (
      tester,
    ) async {
      final failures = <String>[];
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      // Every size and font scale in light mode, every size again in dark.
      final runs = [
        for (final size in _sizes.entries)
          for (final scale in _textScales) (size, scale, ThemeMode.light),
        for (final size in _sizes.entries) (size, 1.0, ThemeMode.dark),
      ];

      for (final (size, scale, themeMode) in runs) {
        Get.testMode = true;
        Get.reset();
        tester.view.devicePixelRatio = 2;
        tester.view.physicalSize = size.value * 2;
        tester.platformDispatcher.textScaleFactorTestValue = scale;

        await tester.pumpWidget(
          GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: child!,
            ),
            home: screen.value(),
          ),
        );
        // Let fake futures complete and loaded content lay out.
        for (var frame = 0; frame < 6; frame += 1) {
          await tester.pump(const Duration(milliseconds: 60));
        }

        final error = tester.takeException();
        if (error != null) {
          final message = error.toString().split('\n').take(4).join(' ');
          failures.add('${size.key} @${scale}x ${themeMode.name}: $message');
        }

        // Unmount before the next size so controllers are disposed.
        await tester.pumpWidget(const SizedBox.shrink());
        tester.takeException();
      }

      Get.reset();
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  }
}
