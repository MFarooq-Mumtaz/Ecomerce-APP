import 'package:get/get.dart';

import '../../modules/auth/login/bindings/login_binding.dart';
import '../../modules/auth/login/view/login_view.dart';
import '../../modules/auth/signup/bindings/signup_binding.dart';
import '../../modules/auth/signup/view/signup_view.dart';
import '../../modules/app_shell/bindings/app_shell_binding.dart';
import '../../modules/app_shell/view/app_shell_view.dart';
import '../../modules/cart/bindings/cart_binding.dart';
import '../../modules/cart/view/cart_view.dart';
import '../../modules/checkout/bindings/checkout_binding.dart';
import '../../modules/checkout/view/checkout_view.dart';
import '../../modules/collection/bindings/collection_binding.dart';
import '../../modules/collection/view/collection_view.dart';
import '../../modules/payment_method/view/payment_method_view.dart';
import '../../modules/product_detail/bindings/product_detail_binding.dart';
import '../../modules/product_detail/view/product_detail_view.dart';
import '../../modules/vendor/become_vendor/bindings/become_vendor_binding.dart';
import '../../modules/vendor/become_vendor/view/become_vendor_view.dart';
import '../../modules/vendor/dashboard/bindings/vendor_dashboard_binding.dart';
import '../../modules/vendor/dashboard/view/vendor_dashboard_view.dart';
import '../../modules/vendor/products/bindings/vendor_products_binding.dart';
import '../../modules/vendor/products/view/vendor_product_form_view.dart';
import '../../modules/vendor/products/view/vendor_products_view.dart';
import '../../modules/wishlist/bindings/wishlist_binding.dart';
import '../../modules/wishlist/view/wishlist_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/view/splash_view.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const AppShellView(),
      binding: AppShellBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentMethod,
      page: () => const PaymentMethodView(),
    ),
    GetPage(
      name: AppRoutes.collection,
      page: () => const CollectionView(),
      binding: CollectionBinding(),
    ),
    GetPage(
      name: AppRoutes.becomeVendor,
      page: () => const BecomeVendorView(),
      binding: BecomeVendorBinding(),
    ),
    GetPage(
      name: AppRoutes.vendorDashboard,
      page: () => const VendorDashboardView(),
      binding: VendorDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.vendorProducts,
      page: () => const VendorProductsView(),
      binding: VendorProductsBinding(),
    ),
    GetPage(
      name: AppRoutes.vendorProductForm,
      page: () => const VendorProductFormView(),
      binding: VendorProductFormBinding(),
    ),
  ];
}
