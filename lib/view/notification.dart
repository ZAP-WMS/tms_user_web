import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/utils/colors.dart';
import '../provider/filter_provider.dart';
import '../service/splash_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/loading_page.dart';
import 'notification_ticket.dart';

int globalIndex = 0;

class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key, required this.userID});
  String userID;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> ticketList = [];
  List<dynamic> ticketid = [];
  List<dynamic> ticketListData = [];

  String work = '';
  String building = '';
  String floor = '';
  String room = '';
  String asset = '';
  String remark = '';
  List<dynamic> serviceprovider = [];

  final String imagePath = 'Images/';
  // List<String> _imageUrls = [];
  bool _isLoading = true;
  // String? userId;
  final SplashService _splashService = SplashService();
  late final FilterProvider filterProvider;

  @override
  void initState() {
    // fetchImageUrls();
    // getNotificationScreenTicket().whenComplete(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      filterProvider = Provider.of<FilterProvider>(context, listen: false);
      filterProvider.fetchAllData(widget.userID).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
    // });

    super.initState();
  }

  // Future<void> fetchImageUrls() async {
  //   ListResult result = await FirebaseStorage.instance.ref('Images/').listAll();
  //   List<String> urls = await Future.wait(
  //     result.items.map((ref) => ref.getDownloadURL()).toList(),
  //   );
  //   _imageUrls = urls;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: 'Notification', isCenter: true, userId: widget.userID),
        body: _isLoading
            ? const Center(child: LoadingPage())
            : Consumer<FilterProvider>(
                builder: (context, value, child) {
                  List<Map<String, dynamic>> dataList =
                      List.from(value.closeData.reversed);
                  return ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        String notificationTime = dataList[index]['date'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return NotificationTicket(
                                    userId: widget.userID,
                                    date: dataList[index]['date'],
                                    ticketNo: dataList[index]['tickets']);
                              },
                            ));
                          },
                          child: notificaionCard(
                              notificationTime,
                              dataList[index]['tickets'],
                              'This ticket has been closed and the case has been resolved'),
                        );
                      });
                },
              ));
  }

  Future<void> getNotificationScreenTicket() async {
    try {
      ticketList.clear();
      QuerySnapshot monthQuery =
          await FirebaseFirestore.instance.collection("raisedTickets").get();
      List<dynamic> dateList = monthQuery.docs.map((e) => e.id).toList();
      for (int j = 0; j < dateList.length; j++) {
        List<dynamic> temp = [];
        QuerySnapshot ticketQuery = await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(dateList[j])
            .collection('tickets')
            .where('user', isEqualTo: widget.userID)
            .where('status', isEqualTo: 'Close')
            .where('isUserSeen', isEqualTo: true)
            .get();
        temp = ticketQuery.docs.map((e) => e.id).toList();
        // ticketList = ticketList + temp;

        if (temp.isNotEmpty) {
          ticketList.addAll(temp);
          for (int k = 0; k < temp.length; k++) {
            DocumentSnapshot ticketDataQuery = await FirebaseFirestore.instance
                .collection("raisedTickets")
                .doc(dateList[j])
                .collection('tickets')
                .doc(temp[k])
                .get();
            if (ticketDataQuery.exists) {
              Map<String, dynamic> mapData =
                  ticketDataQuery.data() as Map<String, dynamic>;
              asset = mapData['asset'].toString();
              building = mapData['building'].toString();
              floor = mapData['floor'].toString();
              remark = mapData['remark'].toString();
              room = mapData['room'].toString();
              work = mapData['work'].toString();
              // serviceprovider = mapData['serviceProvider'].toString();
              ticketListData.add(mapData);
              // print('$mapData abc');
            }
          }
        }
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }
  }

  Widget ticketCard(
      IconData icons, String title, String ticketListData, int index) {
    return Row(
      children: [
        Icon(icons, color: Colors.deepPurple),
        const SizedBox(width: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Text(ticketListData ?? "N/A")
      ],
    );
  }

  Widget listCard(
      IconData icons, String title, List<dynamic> ticketData, int index) {
    return Row(
      children: [
        Icon(icons, color: Colors.deepPurple),
        const SizedBox(width: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Column(
          children: List.generate(
              ticketData.length, (index) => Text(ticketData[index])),
        )
        // Text(ticketData ?? "N/A")
      ],
    );
  }

  Widget notificaionCard(String time, String ticketId, String message) {
    return Card(
      elevation: 5.0,
      margin: const EdgeInsets.all(20),
      child: Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
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
                        style: TextStyle(
                            fontSize: 15,
                            color: AppColors.appBlackColor,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('UserNotification')
                                .doc(time)
                                .collection('tickets')
                                .doc(ticketId)
                                .delete()
                                .whenComplete(() {
                              Provider.of<FilterProvider>(context,
                                      listen: false)
                                  .fetchAllData(widget.userID);
                            });
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
