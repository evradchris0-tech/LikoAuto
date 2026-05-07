import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
    super.key,
  });

  final String phoneNumber;
  final String verificationId;

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyCode(); // Auto verify on last digit
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) return;

    setState(() => _isLoading = true);
    
    try {
      await ref.read(authRepositoryProvider).verifyOTP(
        verificationId: widget.verificationId,
        smsCode: code,
      );
      if (mounted) {
        context.go(AppRoutes.home); // Success! Redirection.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code invalide. Veuillez réessayer.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.trust),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vérification',
                style: context.textStyles.displaySmall?.copyWith(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w800,
                ),
              ),
              AppSpacing.gapSm,
              RichText(
                text: TextSpan(
                  style: context.textStyles.bodyLarge?.copyWith(color: AppColors.neutral, height: 1.5),
                  children: [
                    const TextSpan(text: 'Nous avons envoyé un code à 6 chiffres au\n'),
                    TextSpan(text: widget.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.trust)),
                  ],
                ),
              ),
              AppSpacing.gapXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.trust),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                      ),
                      onChanged: (val) => _onDigitChanged(val, index),
                    ),
                  );
                }),
              ),
              AppSpacing.gapXl,
              PrimaryButton(
                label: 'Vérifier le code',
                isLoading: _isLoading,
                onPressed: _verifyCode,
              ),
              AppSpacing.gapXl,
              Center(
                child: TextButton(
                  onPressed: () {}, // TODO: Resend Logic
                  child: const Text('Renvoyer le code', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
