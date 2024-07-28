import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_pallete.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/loader.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_gradient_button.dart';
import 'login_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TapGestureRecognizer tapGestureRecognizer;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const LoginPage()));
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
    log("Inside signup page");

    ref.listen(
      authViewModelProvider,
      (_, next) {
        next?.when(
          data: (data) {
            showSnackBar(
              context,
              "Account created successfully! Please login.",
            );

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          error: (error, stackTrace) {
            showSnackBar(context, error.toString());
          },
          loading: () {},
        );
      },
    );

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
                          "Sign Up.",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomTextFormField(
                          hintText: "Name",
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [
                            AutofillHints.name,
                          ],
                        ),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          hintText: "Email",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                        ),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          hintText: "Password",
                          controller: passwordController,
                          isObscureText: true,
                        ),
                        const SizedBox(height: 15),
                        AuthGradientButton(
                          buttonText: "Sign Up",
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              await ref
                                  .read(authViewModelProvider.notifier)
                                  .signupUser(
                                    name: nameController.text,
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
                            text: "Already have an account? ",
                            children: [
                              TextSpan(
                                text: "Sign In",
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
