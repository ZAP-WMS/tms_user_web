import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms_useweb_app/controller/module_controller.dart';
import 'package:tms_useweb_app/utils/app_dimensions.dart';
import 'package:tms_useweb_app/utils/colors.dart';
import 'package:tms_useweb_app/utils/text_styles.dart';
import 'package:tms_useweb_app/view/pending_ticket.dart';
import 'package:tms_useweb_app/view/profile.dart';
import 'package:tms_useweb_app/view/raise_ticket.dart';
import 'package:tms_useweb_app/view/ticket_report.dart';
import 'package:tms_useweb_app/widgets/custom_text.dart';
import '../widgets/custom_appbar.dart';
import 'service_provider/serviceprovider_pending.dart';

class HomePage extends StatefulWidget {
  String? userId;
  HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool checkRole = false;
  List<String> images = [];

  List<IconData> icondata = [
    Icons.receipt_long_rounded,
    Icons.pending_actions_outlined,
    Icons.report_sharp,
    Icons.person_outlined,
  ];

  List<IconData> serviceproviderIconData = [
    Icons.pending_actions_outlined,
    Icons.report_sharp,
    Icons.person_outlined,
  ];
  List<String> moduleName = [
    'Raised Ticket',
    'Pending Ticket',
    'Ticket Report',
    'Profile Page'
  ];

  List<String> pageName = [
    'ServiceProvider Pending Ticket',
    'Ticket Report',
    'Profile Page'
  ];

  List<String> serviceProvidermoduleName = [
    'Pending Ticket',
    'Ticket Report',
    'Profile Page'
  ];

  final controller = Get.put(ModuleController());
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    controller.checkRoles(widget.userId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: 'Ticket Manager',
          isCenter: true,
          userId: widget.userId ?? '',
        ),
        body: Obx(() {
          final selectedModule = controller.selectedModule.value;
          return Row(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: AppDimensions.getHeight(context, percentage: 0.001),
                      left:
                          AppDimensions.getHeight(context, percentage: 0.001)),
                  child: Container(
                    width: AppDimensions.getWidth(context, percentage: 0.2),
                    height: AppDimensions.getHeight(context, percentage: 0.2),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                              15), // radius for bottom-left corner
                          bottomRight: Radius.circular(
                              15), // radius for bottom-right corner
                        ),
                        color: AppColors.primaryColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/home/profile.png',
                            width: 100.0, height: 200.0),
                        Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Centers vertically
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // Centers horizontally
                          children: [
                            const SizedBox(
                                height:
                                    10.0), // Add some space between image and text
                            CustomText(
                                text: 'Welcome',
                                textStyle: AppTextStyles.bodyText1,
                                textAlign: TextAlign.center),

                            CustomText(
                                text: widget.userId.toString(),
                                textStyle: AppTextStyles.bodyText1,
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    width: AppDimensions.getWidth(context, percentage: 0.2),
                    child: ListView.builder(
                      itemCount: controller.checkRole.value
                          ? serviceProvidermoduleName.length
                          : moduleName.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            controller.selectModule(controller.checkRole.value
                                ? pageName[index]
                                : moduleName[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.primaryColor),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                    padding: AppDimensions.getPadding(context,
                                        percentage: 0.001),
                                    child: ListTile(
                                      selectedColor: AppColors.primaryColor,
                                      leading: Icon(
                                        controller.checkRole.value
                                            ? serviceproviderIconData[index]
                                            : icondata[index],
                                        color: AppColors.primaryColor,
                                      ),
                                      title: CustomText(
                                        text: controller.checkRole.value
                                            ? serviceProvidermoduleName[index]
                                            : moduleName[index],
                                        textStyle:
                                            AppTextStyles.bodyText1appColor,
                                      ),
                                    ))),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Right Panel: Dynamic Content based on the selected module
            Expanded(
                child: ModuleContent(
              selectedModule: selectedModule,
              userId: widget.userId!,
            ))
          ]);
        }));
  }
}

Future<bool> checkUserRole(String userId) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    // Get the user document from Firestore
    QuerySnapshot<Map<String, dynamic>> userDoc = await _firestore
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (userDoc.docs.isNotEmpty) {
      // Get the first document (assuming userId is unique)
      var document = userDoc.docs.first;

      List? role = document.data()['role'] as List<dynamic>?;
      return role != null && role.isNotEmpty;
    } else {
      print('User not found');
      return false;
    }
  } catch (e) {
    return false;
  }
}

// Widget to display content based on the selected module
class ModuleContent extends StatelessWidget {
  final String selectedModule;
  String userId;

  ModuleContent({Key? key, required this.selectedModule, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // You can map the selected module to different content here
    switch (selectedModule) {
      case 'Raised Ticket':
        return RaiseTicket(userID: userId);
      case 'Pending Ticket':
        return PendingTicket(userId: userId);
      case 'Ticket Report':
        return TicketReport(userID: userId);
      case 'Profile Page':
        return ProfilePage(
          userID: userId,
        );
      case 'ServiceProvider Pending Ticket':
        return ServiceProvidePendingTicket(
            ticketNumber: 'ticketNumber',
            openDate: 'openDate',
            asset: 'asset',
            building: 'building',
            floor: 'floor',
            remark: 'remark',
            room: 'room',
            serviceprovider: 'serviceprovider',
            user: userId,
            work: 'work',
            month: 'month',
            year: 'year');
      default:
        return const Center(child: Text('Module not found'));
    }
  }
}
