import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/widgets/custom_appbar.dart';
import 'package:tms_useweb_app/widgets/inside_pageappBar.dart';
import '../../provider/filter_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/loading_page.dart';

class NotificationScreen_service extends StatefulWidget {
  String userId;
  NotificationScreen_service({super.key, required this.userId});

  @override
  State<NotificationScreen_service> createState() =>
      _NotificationScreen_serviceState();
}

bool _isLoading = true;

late FilterProvider filterProvider;
List<dynamic> ticketList = [];
List<dynamic> ticketListData = [];

class _NotificationScreen_serviceState
    extends State<NotificationScreen_service> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filterProvider = Provider.of<FilterProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: 'Notification', isCenter: true, userId: widget.userId),
        //  AppBar(
        //   automaticallyImplyLeading: false,
        //   backgroundColor: AppColors.primaryColor,
        //   title:
        //       const Text('Notification', style: TextStyle(color: Colors.white)),
        // ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .doc(widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingPage());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Document does not exist.'));
            }

            // Get the data from the document
            Map<String, dynamic>? data =
                snapshot.data!.data() as Map<String, dynamic>;

            if (data == null || !data.containsKey('notifications')) {
              return const Center(child: Text('No notifications field found.'));
            }

            List<dynamic> notifications = data['notifications'];

            if (notifications.isEmpty) {
              return const Center(child: Text('No notifications found.'));
            }
            return ListView.builder(
              reverse: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> notification =
                    notifications[index] as Map<String, dynamic>;
                Timestamp timestamp = notification['timestamp'];
                String username = notification['userName'];
                String ticketId = notification['TicketId'];

                // Ensure this is only called after the build phase
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  filterProvider.addTicketId(ticketId);
                });

                String message =
                    'Ticket has been raised by $username for your attention.'; // Convert Timestamp to DateTime
                DateTime notificationTime = timestamp.toDate();

                DateFormat formatter = DateFormat('yyyy-MM-dd – hh:mm a');
                DateFormat dateformat = DateFormat('dd-MM-yyyy');
                String formattedDate = formatter.format(notificationTime);
                String date = dateformat.format(notificationTime);

                return GestureDetector(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) {
                    //     return NotificationTicket(
                    //       userId: userId,
                    //       date: date.toString(),
                    //       ticketNo: notification['TicketId'],
                    //     );
                    //     //  pendingstatus_service();

                    //     // pending(userID: userId!);
                    //   },
                    // ));
                  },
                  child: notificaionCard(
                      formattedDate, notification['TicketId'], message),
                );
              },
            );
          },
        ));
  }

  // Future<void> getNotificationScreen() async {
  //   try {
  //     ticketList.clear();
  //     QuerySnapshot monthQuery =
  //         await FirebaseFirestore.instance.collection("raisedTickets").get();
  //     List<dynamic> dateList = monthQuery.docs.map((e) => e.id).toList();
  //     for (int j = 0; j < dateList.length; j++) {
  //       List<dynamic> temp = [];
  //       QuerySnapshot ticketQuery = await FirebaseFirestore.instance
  //           .collection("raisedTickets")
  //           .doc(dateList[j])
  //           .collection('tickets')
  //           .where('status', isEqualTo: 'Open')
  //           .where('isSeen', isEqualTo: true)
  //           .get();
  //       temp = ticketQuery.docs.map((e) => e.id).toList();
  //       // ticketList = ticketList + temp;

  //       if (temp.isNotEmpty) {
  //         ticketList.addAll(temp);
  //         for (int k = 0; k < temp.length; k++) {
  //           DocumentSnapshot ticketDataQuery = await FirebaseFirestore.instance
  //               .collection("raisedTickets")
  //               .doc(dateList[j])
  //               .collection('tickets')
  //               .doc(temp[k])
  //               .get();
  //           if (ticketDataQuery.exists) {
  //             Map<String, dynamic> mapData =
  //                 ticketDataQuery.data() as Map<String, dynamic>;

  //             // serviceprovider = mapData['serviceProvider'].toString();
  //             ticketListData.add(mapData);
  //             // print('$mapData abc');
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Error Fetching tickets: $e");
  //   }
  // }

  // Widget ticketCard(
  //     IconData icons, String title, String ticketListData, int index) {
  //   return Row(
  //     children: [
  //       Icon(icons, color: Colors.deepPurple),
  //       const SizedBox(width: 20),
  //       Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  //       const SizedBox(width: 10),
  //       Text(ticketListData ?? "N/A")
  //     ],
  //   );
  // }

  // Widget listCard(
  //     IconData icons, String title, List<dynamic> ticketData, int index) {
  //   return Row(
  //     children: [
  //       Icon(icons, color: Colors.deepPurple),
  //       const SizedBox(width: 20),
  //       Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  //       const SizedBox(width: 10),
  //       Column(
  //         children: List.generate(
  //             ticketData.length, (index) => Text(ticketData[index])),
  //       )
  //       // Text(ticketData ?? "N/A")
  //     ],
  //   );
  // }

  Widget notificaionCard(String time, String ticketId, String message) {
    return Card(
      elevation: 5.0,
      margin: const EdgeInsets.all(10),
      child: Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.appBlackColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        ticketId,
                        style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.appBlackColor,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () async {
                            final FirebaseFirestore _firestore =
                                FirebaseFirestore.instance;
                            DocumentSnapshot userDoc = await FirebaseFirestore
                                .instance
                                .collection('notifications')
                                .doc(widget.userId)
                                .get();

                            if (userDoc.exists) {
                              List<dynamic> notifications =
                                  userDoc.get('notifications') as List<dynamic>;

                              // Step 2: Remove the notification with the matching ticket
                              notifications.removeWhere((notification) =>
                                  notification['TicketId'] == ticketId);

                              // Step 3: Update the array back to Firestore
                              await _firestore
                                  .collection('notifications')
                                  .doc(widget.userId)
                                  .update({'notifications': notifications});

                              print(
                                  'Notification with ticket ${ticketId} removed successfully');
                            } else {
                              print('User document not found');
                            }
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                            size: 20,
                          ))
                    ],
                  )
                ],
              ),
              Text(message)
            ],
          )),
    );
  }
}
