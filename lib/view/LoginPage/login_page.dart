import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_useweb_app/utils/app_dimensions.dart';
import 'package:tms_useweb_app/utils/colors.dart';
import 'package:tms_useweb_app/widgets/loading_page.dart';
import '../../widgets/custom_buton.dart';
import '../../widgets/custom_text_fom.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController userIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/background_img.svg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SvgPicture.asset(
                  'assets/side_img.svg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                Container(
                  padding: AppDimensions.getPadding(context, percentage: 0.01),
                  height: AppDimensions.getHeight(context, percentage: 0.8),
                  width: AppDimensions.getWidth(context, percentage: 0.3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.textWhite),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            AppDimensions.getPadding(context, percentage: 0.01),
                        child: Image.asset('assets/app_logo.png'),
                      ),
                      Center(
                        child: Container(
                          width:
                              AppDimensions.getWidth(context, percentage: 0.2),
                          height:
                              AppDimensions.getHeight(context, percentage: 0.5),
                          padding: AppDimensions.getPadding(context,
                              percentage: 0.02),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.textSecondaryColor),
                              borderRadius: BorderRadius.circular(5)),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomTextFormField(
                                    width: AppDimensions.getWidth(context,
                                        percentage: 0.2),
                                    controller: userIDController,
                                    textInputAction: TextInputAction.next,
                                    label: 'User Id',
                                    hintText: 'UserId'),
                                SizedBox(
                                  height: AppDimensions.getHeight(context,
                                      percentage: 0.02),
                                ),
                                CustomTextFormField(
                                    width: AppDimensions.getWidth(context,
                                        percentage: 0.2),
                                    controller: passwordController,
                                    textInputAction: TextInputAction.next,
                                    label: 'Password',
                                    hintText: 'Password'),
                                SizedBox(
                                    height: AppDimensions.getHeight(context,
                                        percentage: 0.08)),
                                CustomButton(
                                  width: AppDimensions.getWidth(context,
                                      percentage: 0.15),
                                  text: 'LOG IN',
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) => const CupertinoAlertDialog(
                                            content: LoadingPage()
                                            // Column(
                                            //   crossAxisAlignment:
                                            //       CrossAxisAlignment.center,
                                            //   children: [
                                            //     SizedBox(
                                            //       height: 50,
                                            //       width: 50,
                                            //       child: Center(
                                            //         child:
                                            //             CircularProgressIndicator(
                                            //                 color: Color.fromARGB(
                                            //                     255, 151, 64, 69)),
                                            //       ),
                                            //     ),
                                            //     Text(
                                            //       'Verifying..',
                                            //       style: TextStyle(
                                            //           color: Color.fromARGB(
                                            //               255, 151, 64, 69),
                                            //           fontWeight: FontWeight.bold),
                                            //       textAlign: TextAlign.center,
                                            //     )
                                            //   ],
                                            // ),
                                            ),
                                      );
                                      await login(userIDController.text.trim(),
                                          passwordController.text, context);
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> login(
      String userID, String password, BuildContext context) async {
    try {
      QuerySnapshot userDoc = await FirebaseFirestore.instance
          .collection('members')
          .where('userId', isEqualTo: userID)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final storedPassword = userDoc.docs[0]['password'];
        final userName = userDoc.docs[0]['fullName'];

        if (password == storedPassword) {
          storeLoginData(true, userIDController.text, userName);

          // ignore: use_build_context_synchronously
          Navigator.pushAndRemoveUntil(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        userId: userIDController.text,
                      )),
              (route) => false).then((value) {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          });
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          SnackBar snackBar = const SnackBar(
              backgroundColor: Colors.red,
              content: Center(
                child: Text('Incorrect Password'),
              ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        SnackBar snackBar = const SnackBar(
            backgroundColor: Colors.red,
            content: Center(
              child: Text('User does not exist'),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void storeLoginData(bool isLogin, String userID, String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userID');
    prefs.setBool('isLogin', isLogin);
    prefs.setString('userID', userID);
    prefs.setString('userName', userName);
  }
}
