import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;
  late TextEditingController _footerController;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _upiController = TextEditingController();
    _footerController = TextEditingController();
    context.read<ShopBloc>().add(LoadShopEvent());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  void _updateControllers(Shop shop) {
    if (_nameController.text.isEmpty && shop.name.isNotEmpty) {
      _nameController.text = shop.name;
      _address1Controller.text = shop.addressLine1;
      _address2Controller.text = shop.addressLine2;
      _phoneController.text = shop.phoneNumber;
      _upiController.text = shop.upiId;
      _footerController.text = shop.footerText;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      context.read<ShopBloc>().add(UpdateShopEvent(Shop(
            name: _nameController.text,
            addressLine1: _address1Controller.text,
            addressLine2: _address2Controller.text,
            phoneNumber: _phoneController.text,
            upiId: _upiController.text,
            footerText: _footerController.text,
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Shop Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ShopBloc, ShopState>(
        listener: (context, state) {
          if (state is ShopLoaded) _updateControllers(state.shop);
          if (state is ShopOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Shop details saved'),
                ]),
                backgroundColor: AppTheme.accentColor,
              ),
            );
            context.pop();
          } else if (state is ShopError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ));
          }
        },
        buildWhen: (p, c) => c is ShopLoading || c is ShopLoaded,
        builder: (context, state) {
          if (state is ShopLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          return FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      icon: Icons.storefront_outlined,
                      iconColor: AppTheme.primaryColor,
                      iconBg: AppTheme.primaryLight,
                      title: 'Business Info',
                      subtitle: 'Appears on all receipts',
                      children: [
                        const InputLabel(text: 'Shop Name', required: true),
                        _field(
                            controller: _nameController,
                            hint: 'e.g. QuickMart Superstore',
                            icon: Icons.storefront_outlined,
                            validator:
                                AppValidators.required('Required')),
                        const SizedBox(height: 16),
                        const InputLabel(
                            text: 'Address Line 1', required: true),
                        _field(
                            controller: _address1Controller,
                            hint: 'Street, Area',
                            icon: Icons.location_on_outlined,
                            validator:
                                AppValidators.required('Required')),
                        const SizedBox(height: 16),
                        const InputLabel(
                            text: 'Address Line 2 (Optional)'),
                        _field(
                            controller: _address2Controller,
                            hint: 'City, PIN code',
                            icon: Icons.location_city_outlined),
                        const SizedBox(height: 16),
                        const InputLabel(
                            text: 'Phone Number', required: true),
                        _field(
                            controller: _phoneController,
                            hint: '+91 9876543210',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator:
                                AppValidators.required('Required')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppTheme.warningColor,
                      iconBg: AppTheme.warningLight,
                      title: 'Payment',
                      subtitle: 'UPI QR shown at checkout',
                      children: [
                        const InputLabel(text: 'UPI ID'),
                        _field(
                            controller: _upiController,
                            hint: 'yourname@upi',
                            icon: Icons.qr_code_rounded),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppTheme.accentColor,
                      iconBg: AppTheme.accentLight,
                      title: 'Receipt',
                      subtitle: 'Footer message on printed receipts',
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const InputLabel(text: 'Footer Text'),
                            Text('Max 60 chars',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[400])),
                          ],
                        ),
                        _field(
                            controller: _footerController,
                            hint: 'Thank you! Visit again.',
                            icon: Icons.format_quote_rounded,
                            maxLines: 2,
                            maxLength: 60),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _saveShop,
        icon: Icons.save_rounded,
        label: 'Save Details',
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
      ),
    );
  }
}
