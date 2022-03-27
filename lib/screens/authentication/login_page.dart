import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/utils/authentication_client.dart';
import 'package:deepgram_transcribe/utils/database_client.dart';
import 'package:deepgram_transcribe/widgets/wave_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/validators.dart';
import '../dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();

  late final TextEditingController _emailTextController;
  late final TextEditingController _passwordTextController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final AuthenticationClient _authClient;
  late final DatabaseClient _databaseClient;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _emailTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _authClient = AuthenticationClient();
    _databaseClient = DatabaseClient();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.white,
    //   statusBarIconBrightness: Brightness.dark,
    // ));
    return GestureDetector(
      onTap: () {
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
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
        body: SingleChildScrollView(
          child: Form(
            key: _loginFormKey,
            onChanged: () => setState(() {}),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 56.0,
                vertical: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailTextController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
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
                    textInputAction: TextInputAction.done,
                    focusNode: _passwordFocusNode,
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
                      hintText: 'Enter password',
                      hintStyle: TextStyle(
                        fontSize: 20,
                        color: CustomColors.black.withOpacity(0.5),
                      ),
                    ),
                    validator: (value) => Validators.validatePassword(
                      password: value,
                    ),
                    // onChanged: (value) => widget.onChange(value),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    children: [
                      const Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register',
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
                            isBarVisible: false,
                            isPaused: false,
                          ),
                        )
                      : SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: CustomColors.black,
                              onSurface: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () async {
                              if (_loginFormKey.currentState!.validate()) {
                                setState(() {
                                  _isProcessing = true;
                                });

                                final user =
                                    await _authClient.signInUsingEmailPassword(
                                  email: _emailTextController.text,
                                  password: _passwordTextController.text,
                                );

                                setState(() {
                                  _isProcessing = false;
                                });

                                if (user != null) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DashboardPage(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Sign In',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 30),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Skip signing in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
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
    );
  }
}
