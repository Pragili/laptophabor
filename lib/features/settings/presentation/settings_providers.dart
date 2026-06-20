import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session-scoped user preferences. (Swap the Notifier body for persistent
/// storage later if you want them to survive restarts.)
class AppSettings {
  final bool orderUpdates;
  final bool promotions;
  final bool emailReceipts;
  const AppSettings({
    this.orderUpdates = true,
    this.promotions = false,
    this.emailReceipts = true,
  });

  AppSettings copyWith({bool? orderUpdates, bool? promotions, bool? emailReceipts}) =>
      AppSettings(
        orderUpdates: orderUpdates ?? this.orderUpdates,
        promotions: promotions ?? this.promotions,
        emailReceipts: emailReceipts ?? this.emailReceipts,
      );
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setOrderUpdates(bool v) => state = state.copyWith(orderUpdates: v);
  void setPromotions(bool v) => state = state.copyWith(promotions: v);
  void setEmailReceipts(bool v) => state = state.copyWith(emailReceipts: v);
}
