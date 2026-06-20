/// Centralised route paths. Screens reference these constants only,
/// never raw strings — keeps navigation refactors safe.
class RouteNames {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot';

  static const home = '/home';
  static const search = '/search';
  static const listing = '/listing';
  static const product = '/product'; // used as '$product/$id'

  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';

  static const wishlist = '/wishlist';
  static const profile = '/profile';
  static const settings = '/settings';
  static const orders = '/orders';
  static const notifications = '/notifications';
  static const faq = '/faq';

  static const adminDashboard = '/admin';
}
