class AppConstants {
  AppConstants._();

  // Informasi Toko - dapat diubah sesuai kebutuhan
  static const String storeName = 'Toko Sederhana';
  static const String storeAddress = 'Jl. Merdeka No. 10, Bandung';
  static const String storePhone = '0812-3456-7890';
  static const String thankYouMessage = 'Terima kasih telah berbelanja di toko kami!';

  // Database
  static const String dbName = 'pos_toko.db';
  static const int dbVersion = 1;

  static const String tableProducts = 'products';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';
}
