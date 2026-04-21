import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final TextStyle textStyle;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.textStyle,
    this.borderColor,
    this.boxShadow,
  });

  factory SocialLoginButton.apple({required VoidCallback onPressed}) {
    return SocialLoginButton(
      label: 'Sign in with Apple',
      icon: const Icon(Icons.apple, color: AppColors.white, size: 24),
      onPressed: onPressed,
      backgroundColor: AppColors.black,
      textStyle: AppTextStyles.buttonTextWhite,
    );
  }

  factory SocialLoginButton.google({required VoidCallback onPressed}) {
    return SocialLoginButton(
      label: 'Sign in with Google',
      icon: Image.network(
        'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
        height: 24,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: AppColors.primaryBlue, size: 24),
      ),
      onPressed: onPressed,
      backgroundColor: AppColors.white,
      textStyle: AppTextStyles.buttonTextBlack,
      borderColor: AppColors.divider,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
