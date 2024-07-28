import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_pallete.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/loader.dart';
import '../widgets/auth_gradient_button.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../../home/view/pages/home_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TapGestureRecognizer tapGestureRecognizer;
  late final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => const SignupPage()));
        Navigator.of(context).pop();
      };
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
        authViewModelProvider.select((value) => value?.isLoading == true));
    log("Inside login page");

    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
            (route) => false,
          );
        },
        error: (error, stackTrace) {
          showSnackBar(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Pallete.backgroundColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Pallete.backgroundColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Pallete.backgroundColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Sign In.",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomTextFormField(
                          hintText: "Email",
                          controller: emailController,
                        ),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          hintText: "Password",
                          controller: passwordController,
                          isObscureText: true,
                        ),
                        const SizedBox(height: 15),
                        AuthGradientButton(
                          buttonText: "Sign In",
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              await ref
                                  .read(authViewModelProvider.notifier)
                                  .loginUser(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                            } else {
                              showSnackBar(context, "Missing fields!");
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.titleMedium,
                            text: "Don't have an account? ",
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: const TextStyle(
                                  color: Pallete.gradient2,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: tapGestureRecognizer,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
