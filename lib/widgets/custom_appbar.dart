import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/service/auth_services.dart';
import '../controller/module_controller.dart';
import '../provider/filter_provider.dart';
import '../utils/colors.dart';
import '../view/notification.dart';
import '../view/service_provider/serviceNotification.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  bool isCenter = false;
  String userId;

  CustomAppBar(
      {required this.title,
      required this.isCenter,
      this.actions,
      required this.userId});

  @override
  Widget build(BuildContext context) {
    AuthService authservice = AuthService();
    final controller = Get.put(ModuleController());
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.backgroundColor)),
      backgroundColor: AppColors.primaryColor,
      centerTitle: isCenter,
      leading: IconButton(
        onPressed: () {
          Get.toNamed('/home', arguments: {'userId': userId});
        },
        icon: const Icon(
          Icons.home,
          color: AppColors.backgroundColor,
        ),
      ),
      actions: [
        // IconButton(
        //     onPressed: () {
        //       if (controller.checkRole.value) {
        //         {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => NotificationScreen_service(
        //                         userId: userId,
        //                       ))).whenComplete(() async {
        //             await Provider.of<FilterProvider>(context, listen: false)
        //                 .updateServiceUserSeen(userId)
        //                 .whenComplete(() {
        //               Provider.of<FilterProvider>(context, listen: false)
        //                   .getServiceNotificatioLength(userId);
        //             });
        //           });
        //         }
        //       } else {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => NotificationScreen(
        //               userID: userId,
        //             ),
        //           ),
        //         ).whenComplete(() async {
        //           await Provider.of<FilterProvider>(context, listen: false)
        //               .updateUserSeen(userId);
        //           // ignore: use_build_context_synchronously
        //           await Provider.of<FilterProvider>(context, listen: false)
        //               .getNotificationLength(userId);
        //         });
        //       }
        //     },
        //icon:
        Stack(children: [
          IconButton(
            onPressed: () {
              if (controller.checkRole.value) {
                {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationScreen_service(
                                userId: userId,
                              ))).whenComplete(() async {
                    await Provider.of<FilterProvider>(context, listen: false)
                        .updateServiceUserSeen(userId)
                        .whenComplete(() {
                      Provider.of<FilterProvider>(context, listen: false)
                          .getServiceNotificatioLength(userId);
                    });
                  });
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(
                      userID: userId,
                    ),
                  ),
                ).whenComplete(() async {
                  await Provider.of<FilterProvider>(context, listen: false)
                      .updateUserSeen(userId);
                  // ignore: use_build_context_synchronously
                  await Provider.of<FilterProvider>(context, listen: false)
                      .getNotificationLength(userId);
                });
              }
            },
            icon: const Icon(
              size: 25,
              Icons.notifications_active,
              color: AppColors.textWhite,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Consumer<FilterProvider>(
              builder: (context, filterProvider, child) {
                return filterProvider.userSeen.isNotEmpty
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          filterProvider.userSeen.length.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ]),
        IconButton(
          onPressed: () {
            authservice.logout(context);
          },
          icon: const Icon(
            Icons.logout,
            color: AppColors.backgroundColor,
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
