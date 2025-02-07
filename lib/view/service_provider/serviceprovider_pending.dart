import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/utils/colors.dart';
import 'package:tms_useweb_app/widgets/inside_pageappBar.dart';
import '../../provider/filter_provider.dart';
import '../../utils/app_dimensions.dart';
import 'package:http/http.dart' as http;

class ServiceProvidePendingTicket extends StatefulWidget {
  ServiceProvidePendingTicket(
      {super.key,
      this.ticketNumber,
      this.openDate,
      this.asset,
      this.building,
      this.floor,
      this.remark,
      this.room,
      this.serviceprovider,
      this.user,
      this.work,
      this.month,
      this.year});
  String? ticketNumber;
  String? asset;
  String? building;
  String? floor;
  String? remark;
  String? room;
  String? work;
  String? openDate;
  String? month;
  String? year;
  String? serviceprovider;
  String? user;

  @override
  State<ServiceProvidePendingTicket> createState() =>
      _ServiceProvidePendingTicketState();
}

class _ServiceProvidePendingTicketState
    extends State<ServiceProvidePendingTicket> {
  List<dynamic> ticketList = [];
  List<dynamic> ticketListData = [];
  bool isLoading = true;
  List<dynamic> icons = [];
  List<dynamic> titles = [];
  List<dynamic> message = [];

  final dateFormatter = DateFormat('yyyy-MM-dd');
  final timeFormatter = DateFormat('HH:mm:ss');
  late final FilterProvider filterProvider;

  @override
  void initState() {
    filterProvider = Provider.of<FilterProvider>(context, listen: false);
    Provider.of<FilterProvider>(context, listen: false)
        .fetchPendingTicketData(widget.user ?? '');

    super.initState();
  }

  Future<void> getPendingTicket() async {
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
            .where('status', isEqualTo: 'Open')
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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    icons = [
      Icons.work,
      Icons.business,
      Icons.layers,
      Icons.room,
      Icons.account_balance,
      Icons.comment,
      Icons.design_services
    ];
    titles = [
      'Work',
      'Building',
      'Floor',
      'Room',
      'Assets',
      'Remark',
      'Service Provider'
    ];

    return Scaffold(
      appBar: commonAppBar(
        title: 'Tickets',
        onBackPressed: () {},
      ),
      body: Consumer<FilterProvider>(
        builder: (context, value, child) {
          return value.serviceLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ))
              : value.servicependingData.isNotEmpty
                  ? GridView.builder(
                      padding:
                          AppDimensions.getPadding(context, percentage: 0.05),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 1.2,
                              childAspectRatio: 1.0,
                              crossAxisCount: 3),
                      itemCount: value.servicependingData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: AppDimensions.getPadding(context,
                              percentage: 0.005),
                          color: const Color.fromARGB(255, 240, 210, 247),
                          elevation: 10,
                          shadowColor: Colors.red,
                          child: Container(
                            width: AppDimensions.getWidth(context,
                                percentage: 0.05),
                            height: AppDimensions.getHeight(context,
                                percentage: 0.2),
                            padding: AppDimensions.getPadding(context,
                                percentage: 0.02),
                            child: Column(
                              children: [
                                Text(value.servicependingData[index]['tickets'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Expanded(
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: titles.length,
                                    itemBuilder: (context, index2) {
                                      message = [
                                        value.servicependingData[index]['work'],
                                        value.servicependingData[index]
                                            ['building'],
                                        value.servicependingData[index]
                                            ['floor'],
                                        value.servicependingData[index]['room'],
                                        value.servicependingData[index]
                                            ['asset'],
                                        value.servicependingData[index]
                                                ['remark']
                                            .toString(),
                                        value.servicependingData[index]
                                            ['serviceProvider'],
                                      ];
                                      return Column(
                                        children: [
                                          customCard(icons[index2],
                                              titles[index2], message[index2]),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primaryColor),
                                    onPressed: () {
                                      customAlert(
                                          value.servicependingData[index]
                                              ['date'],
                                          value.servicependingData[index]
                                              ['tickets']);
                                    },
                                    child: const Text(
                                      "Task Accomplished",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ))
                              ],
                            ),
                          ),
                        );
                      })
                  : const Center(
                      child: Text(
                        'No tickets Available',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    );
        },
      ),
    );
  }

  Future storeCompletedTicket(
      // String year, String month,
      String documents,
      String ticketNumber) async {
    Navigator.pop(context);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 151, 64, 69)),
              ),
            ),
            Text(
              'Solving...',
              style: TextStyle(
                  color: Color.fromARGB(255, 151, 64, 69),
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );

    String currentMonth = DateFormat('MMM').format(DateTime.now());
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    DateTime a1 = DateFormat('dd-MM-yyyy').parse(documents);
    DateTime a2 = DateFormat('dd-MM-yyyy').parse(currentDate);
    Duration a3 = a2.difference(a1);
    print("Duration $a3");

    FirebaseFirestore.instance
        .collection("raisedTickets")
        .doc(documents)
        .collection('tickets')
        .doc(ticketNumber)
        .update({
      'status': 'Close',
      'tat': a3.inDays,
      "isSeen": false,
      "isUserSeen": true,
      'closedDate': currentDate
    }).whenComplete(() async {
      await FirebaseFirestore.instance
          .collection("UserNotification")
          .doc(documents)
          .collection('tickets')
          .doc(ticketNumber)
          .update({
        'status': 'Close',
        'tat': a3.inDays,
        "isSeen": false,
        "isUserSeen": true,
        'closedDate': currentDate
      });
      await getFcmToken(widget.user!).then((fcmToken) {
        if (fcmToken.isNotEmpty) {
          sendNotificationViaGet('https://tms-notification.onrender.com/not/',
              fcmToken, ticketNumber, 'Your Ticket has been Closed.');

          print('FCM Token: $fcmToken');
        } else {
          print('FCM Token not found');
        }
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text(
              "Ticket Resolved!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void customAlert(String documents, String ticketNumber) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Are You Sure Task Is Completed!",
            ),
            icon: const Icon(
              Icons.warning,
              color: Colors.blue,
              size: 60,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // if (widget.year!.isNotEmpty &&
                      //     widget.month!.isNotEmpty &&
                      //     widget.openDate!.isNotEmpty &&
                      //     widget.ticketNumber!.isNotEmpty) {
                      final DateTime now = DateTime.now();
                      final formattedDate = dateFormatter.format(now);
                      final formattedTime = timeFormatter.format(now);
                      storeCompletedTicket(documents, ticketNumber);
                    },
                    //  },
                    child: const Text(
                      "OK",
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  Widget customCard(IconData icons, String title, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icons, color: Color.fromARGB(255, 197, 66, 73)),
              const SizedBox(width: 10),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 100,
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${_addLeadingZero(now.month)}-${_addLeadingZero(now.day)}';
  }

  String _addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  Future<void> getTicketData() async {
    try {
      ticketList.clear();
      String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      int currentYear = DateTime.now().year;

      String currentMonth = DateFormat('MMM').format(DateTime.now());

      QuerySnapshot monthQuery = await FirebaseFirestore.instance
          .collection("raisedTickets")
          .doc(currentYear.toString())
          .collection('months')
          .get();
      List<dynamic> months = monthQuery.docs.map((e) => e.id).toList();
      for (int i = 0; i < months.length; i++) {
        QuerySnapshot dateQuery = await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(currentYear.toString())
            .collection('months')
            .doc(months[i])
            .collection('date')
            .get();
        List<dynamic> dateList = dateQuery.docs.map((e) => e.id).toList();
        for (int j = 0; j < dateList.length; j++) {
          List<dynamic> temp = [];
          QuerySnapshot ticketQuery = await FirebaseFirestore.instance
              .collection("raisedTickets")
              .doc(currentYear.toString())
              .collection('months')
              .doc(months[i])
              .collection('date')
              .doc(dateList[j])
              .collection('tickets')
              .get();
          temp = ticketQuery.docs.map((e) => e.id).toList();
          ticketList = ticketList + temp;
        }
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }
  }

  Future<void> sendNotificationViaGet(
      String url, String token, String title, String message) async {
    final queryParameters = {
      'token': token,
      'title': title,
      'message': message,
    };

    // Construct the URI with query parameters
    final uri = Uri.parse(url);
    //.replace(queryParameters: queryParameters);
    print(uri);

    try {
      final response = await http.post(uri,
          headers: {
            'Content-Type':
                'application/json', // Set content type if sending JSON
          },
          body: jsonEncode(queryParameters));
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response body if needed
        final data = response.body;
        print('Response data: $data');
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> getFcmToken(String userId) async {
    try {
      // Fetch the document for the given userId
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('FcmToken')
          .doc(userId)
          .get();

      // Check if the document exists
      if (userDoc.exists) {
        // Retrieve the token from the document
        String fcmToken = userDoc[
            'fcmToken']; // 'token' is the field where the FCM token is stored
        return fcmToken;
      } else {
        // Handle case where document does not exist
        return '';
      }
    } catch (e) {
      // Handle any errors
      print('Error fetching FCM token: $e');
      return '';
    }
  }
}
