import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_useweb_app/utils/app_dimensions.dart';
import 'package:tms_useweb_app/widgets/inside_pageappBar.dart';
import '../../widgets/custom_buton.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class ProfilePage extends StatefulWidget {
  String userID;
  ProfilePage({super.key, required this.userID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    getUserRole();
    super.initState();
  }

  getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? 'DefaultUser';
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: commonAppBar(title: 'Profile Page', onBackPressed: () {}),
      body: Padding(
        padding: AppDimensions.getPadding(context, percentage: 0.05),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryColor)),
                    child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.backgroundColor,
                        child: Image.asset('assets/home/profile.png',
                            color: AppColors.primaryColor, height: 100)),
                  ),
                  Text(userName.toString(),
                      style: AppTextStyles.boldBlackColor),
                  Text(widget.userID, style: AppTextStyles.boldBlackColor),
                  const SizedBox(height: 10),
                  CustomButton(
                    width: 150,
                    textColor: AppColors.primaryColor,
                    color: AppColors.backgroundColor,
                    text: 'Edit Profile',
                    onPressed: () {},
                  )
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: const Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('Change Password'),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Refer Friends'),
                      trailing: Icon(Icons.arrow_forward_ios),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
