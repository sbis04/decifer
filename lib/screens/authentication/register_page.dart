import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/utils/authentication_client.dart';
import 'package:deepgram_transcribe/widgets/wave_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/validators.dart';
import '../dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  late final TextEditingController _nameTextController;
  late final TextEditingController _emailTextController;
  late final TextEditingController _passwordTextController;
  late final TextEditingController _confirmPasswordTextController;

  late final FocusNode _nameFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _confirmPasswordFocusNode;
  late final AuthenticationClient _authClient;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _nameTextController = TextEditingController();
    _emailTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    _confirmPasswordTextController = TextEditingController();
    _authClient = AuthenticationClient();

    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _nameFocusNode.unfocus();
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _confirmPasswordFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          iconTheme: const IconThemeData(
            color: CustomColors.black,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _registerFormKey,
              onChanged: () => setState(() {}),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 56.0, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameTextController,
                      focusNode: _nameFocusNode,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        fontSize: 20,
                        color: CustomColors.black.withOpacity(0.8),
                      ),
                      cursorColor: CustomColors.black,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black,
                            width: 3,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: CustomColors.black.withOpacity(0.5),
                        ),
                        hintText: 'Enter name',
                      ),
                      validator: (value) => Validators.validateName(
                        name: value,
                      ),
                      // onChanged: (value) => widget.onChange(value),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailTextController,
                      focusNode: _emailFocusNode,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        fontSize: 20,
                        color: CustomColors.black.withOpacity(0.8),
                      ),
                      cursorColor: CustomColors.black,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black,
                            width: 3,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: CustomColors.black.withOpacity(0.5),
                        ),
                        hintText: 'Enter email',
                      ),
                      validator: (value) => Validators.validateEmail(
                        email: value,
                      ),
                      // onChanged: (value) => widget.onChange(value),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      obscureText: true,
                      controller: _passwordTextController,
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        fontSize: 20,
                        color: CustomColors.black.withOpacity(0.8),
                      ),
                      cursorColor: CustomColors.black,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black,
                            width: 3,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: CustomColors.black.withOpacity(0.5),
                        ),
                        hintText: 'Enter password',
                      ),
                      validator: (value) => Validators.validatePassword(
                        password: value,
                      ),
                      // onChanged: (value) => widget.onChange(value),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      obscureText: true,
                      controller: _confirmPasswordTextController,
                      focusNode: _confirmPasswordFocusNode,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        fontSize: 20,
                        color: CustomColors.black.withOpacity(0.8),
                      ),
                      cursorColor: CustomColors.black,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black,
                            width: 3,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: CustomColors.black.withOpacity(0.5),
                        ),
                        hintText: 'Confirm password',
                      ),
                      validator: (value) => Validators.validateConfirmPassword(
                        password: _passwordTextController.text,
                        confirmPassword: value,
                      ),
                      // onChanged: (value) => widget.onChange(value),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CustomColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _isProcessing
                        ? SizedBox(
                            height: 60,
                            width: double.maxFinite,
                            child: WaveVisualizer(
                              columnHeight: 50,
                              columnWidth: 10,
                            ),
                          )
                        : SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: CustomColors.black,
                                onSurface: CustomColors.black.withOpacity(0.5),
                              ),
                              onPressed: () async {
                                if (_registerFormKey.currentState!.validate()) {
                                  setState(() {
                                    _isProcessing = true;
                                  });

                                  final user = await _authClient
                                      .registerUsingEmailPassword(
                                    name: _nameTextController.text,
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text,
                                  );

                                  setState(() {
                                    _isProcessing = false;
                                  });

                                  if (user != null) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => DashboardPage(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
