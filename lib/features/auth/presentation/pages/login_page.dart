import 'package:beacon/core/theme/app_colors.dart';
import 'package:beacon/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/auth_divider.dart';
import '../widgets/email_input_field.dart';
import '../widgets/secure_badge.dart';
import '../widgets/social_login_button.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state is AuthMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: AppColors.logoGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.white,
                      size: 56,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Welcome Text
                const Text(
                  'Welcome to Proximity Aware',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Stay connected with precision location tracking and real-time proximity alerts.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 48),
                // Social Buttons
                SocialLoginButton.apple(
                  onPressed: () => context.read<AuthBloc>().add(
                    const SignInWithAppleRequested(),
                  ),
                ),
                const SizedBox(height: 16),
                SocialLoginButton.google(
                  onPressed: () => context.read<AuthBloc>().add(
                    const SignInWithGoogleRequested(),
                  ),
                ),
                const SizedBox(height: 40),
                // Divider
                const AuthDivider(),
                const SizedBox(height: 40),
                // Email Input
                EmailInputField(
                  controller: _emailController,
                  onSubmitted: () {
                    // Reverted to single email field flow.
                    // If your Firebase project uses Passwordless/Magic Link, 
                    // this would trigger that flow.
                  },
                ),
                const SizedBox(height: 32),
                // Secure Badge
                const SecureBadge(),
                const SizedBox(height: 60),
                // Footer
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text(
                      'By signing in, you agree to our ',
                      style: AppTextStyles.footerText,
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Terms of Service',
                        style: AppTextStyles.footerLink,
                      ),
                    ),
                    const Text(' and ', style: AppTextStyles.footerText),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Privacy Policy',
                        style: AppTextStyles.footerLink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/**
 * --- INTERVIEW PREP: HOW BLOC ACCESS WORKS ---
 * 
 * If asked: "How does the UI access 'SignInWithGoogleRequested'?"
 * 
 * 1. The Provider: In 'main.dart', we wrapped the app in a 'BlocProvider'. 
 *    This puts the 'AuthBloc' into the "Context" (the environment) of the app.
 * 
 * 2. The Bridge (context.read): When we call 'context.read<AuthBloc>()', 
 *    Flutter looks up the tree to find that provided 'AuthBloc'.
 * 
 * 3. The Event (.add): We are NOT accessing a stream directly here. 
 *    We are "Adding an Event" to the Bloc's sink.
 * 
 * ⚠️ Clarification on your answer:
 * You might have confused 'BlocProvider' with a regular 'Stream'. 
 * While Bloc uses Streams internally, 'context.read' is a feature of the 
 * 'provider' package that Bloc is built upon. It's the "Delivery Service" 
 * for the Bloc.
 */
