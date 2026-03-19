import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    context.read<PrinterBloc>().add(InitPrinterEvent());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(),
              const SizedBox(height: 24),

              // Quick stats
              _buildQuickStats(),
              const SizedBox(height: 24),

              // Management section
              _buildSectionLabel('Management'),
              const SizedBox(height: 8),
              _buildMenuGroup([
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  iconBg: AppTheme.primaryLight,
                  iconColor: AppTheme.primaryColor,
                  title: 'Products',
                  subtitle: 'Manage stock & barcodes',
                  onTap: () => context.push('/products'),
                ),
                _MenuItem(
                  icon: Icons.storefront_outlined,
                  iconBg: AppTheme.accentLight,
                  iconColor: AppTheme.accentColor,
                  title: 'Shop Details',
                  subtitle: 'Business info & receipt settings',
                  onTap: () => context.push('/shop'),
                ),
              ]),

              const SizedBox(height: 24),

              // Hardware section
              _buildSectionLabel('Hardware'),
              const SizedBox(height: 8),
              _buildPrinterSection(),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Pair your printer in Bluetooth settings first, then tap Refresh.',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        String shopName = 'My Shop';
        String initials = 'MS';
        if (state is ShopLoaded && state.shop.name.isNotEmpty) {
          shopName = state.shop.name;
          final parts = shopName.split(' ');
          initials = parts
              .take(2)
              .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
              .join('');
          if (initials.isEmpty) initials = 'S';
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'POS System',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/shop'),
                icon: const Icon(Icons.edit_rounded,
                    color: Colors.white70, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        String phone = '—';
        String upi = '—';
        if (state is ShopLoaded) {
          if (state.shop.phoneNumber.isNotEmpty) phone = state.shop.phoneNumber;
          if (state.shop.upiId.isNotEmpty) upi = state.shop.upiId;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                  child: _StatCard(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: phone,
                      color: AppTheme.accentColor,
                      bg: AppTheme.accentLight)),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'UPI',
                      value: upi,
                      color: AppTheme.warningColor,
                      bg: AppTheme.warningLight)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuItem(item),
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    color: AppTheme.borderColor,
                    indent: 68,
                    endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.borderColor, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterSection() {
    return BlocConsumer<PrinterBloc, PrinterState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppTheme.errorColor,
          ));
        } else if (state.status == PrinterStatus.connected) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Printer connected'),
            ]),
            backgroundColor: AppTheme.accentColor,
          ));
        }
      },
      builder: (context, state) {
        final isConnected = state.connectedMac != null;
        final isBusy = state.status == PrinterStatus.scanning ||
            state.status == PrinterStatus.connecting;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isConnected
                        ? AppTheme.accentLight
                        : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.print_rounded,
                    color: isConnected
                        ? AppTheme.accentColor
                        : AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bluetooth Printer',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? AppTheme.accentColor
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected
                                ? (state.connectedName ?? 'Connected')
                                : 'Not connected',
                            style: TextStyle(
                                fontSize: 12,
                                color: isConnected
                                    ? AppTheme.accentColor
                                    : AppTheme.textSecondary,
                                fontWeight: isConnected
                                    ? FontWeight.w600
                                    : FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isBusy)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryColor),
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppTheme.primaryColor),
                    onPressed: () =>
                        context.read<PrinterBloc>().add(RefreshPrinterEvent()),
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_bluetooth_rounded,
                        color: AppTheme.textSecondary),
                    onPressed: () => AppSettings.openAppSettings(
                        type: AppSettingsType.bluetooth),
                    tooltip: 'Bluetooth Settings',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500)),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
