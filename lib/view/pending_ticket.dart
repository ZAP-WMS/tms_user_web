import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tms_useweb_app/utils/app_dimensions.dart';
import 'package:tms_useweb_app/widgets/inside_pageappBar.dart';

class PendingTicket extends StatefulWidget {
  String userId;
  PendingTicket({super.key, required this.userId});

  @override
  State<PendingTicket> createState() => _PendingTicketState();
}

class _PendingTicketState extends State<PendingTicket> {
  List<dynamic> ticketList = [];
  List<dynamic> ticketListData = [];

  String work = '';
  String building = '';
  String floor = '';
  String room = '';
  String asset = '';
  String remark = '';
  List<dynamic> serviceprovider = [];
  List<dynamic> titles = [];
  List<dynamic> icons = [];
  List<dynamic> message = [];

  final String imagePath = 'Images/';
  List<String> _imageUrls = [];
  bool _isLoading = true;
  @override
  void initState() {
    fetchImageUrls();
    getPendingTicket().whenComplete(() async {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  Future<void> fetchImageUrls() async {
    ListResult result = await FirebaseStorage.instance.ref('Images/').listAll();
    List<String> urls = await Future.wait(
      result.items.map((ref) => ref.getDownloadURL()).toList(),
    );
    _imageUrls = urls;
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: commonAppBar(title: 'Pending Tickets', onBackPressed: () {}),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ticketList.isNotEmpty
                ? GridView.builder(
                    padding:
                        AppDimensions.getPadding(context, percentage: 0.05),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 1.2,
                            childAspectRatio: 1.0,
                            crossAxisCount: 3),
                    itemCount: ticketList.length,
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
                                  Text(ticketListData[index]['tickets'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Expanded(
                                    child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: titles.length,
                                        itemBuilder:
                                            (BuildContext context, int index2) {
                                          message = [
                                            ticketListData[index]['work'],
                                            ticketListData[index]['building'],
                                            ticketListData[index]['floor'],
                                            ticketListData[index]['room'],
                                            ticketListData[index]['asset'],
                                            ticketListData[index]['remark']
                                                .toString(),
                                            ticketListData[index]
                                                ['serviceProvider']
                                          ];

                                          return customCard(icons[index2],
                                              titles[index2], message[index2]);
                                        }),
                                  ),
                                ],
                              )));
                    },
                  )
                : const Center(
                    child: Text('No Tickets Avilable'),
                  ));
  }

  Widget customCard(IconData icons, String title, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icons, color: const Color.fromARGB(255, 197, 66, 73)),
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
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
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
            .where('user', isEqualTo: widget.userId)
            .where('status', isEqualTo: 'Open')
            .get();
        temp = ticketQuery.docs.map((e) => e.id).toList();
        // ticketList = ticketList + temp;
        temp = temp.reversed.toList();
        if (temp.isNotEmpty) {
          ticketList.addAll(temp);
          // ticketList = ticketList.reversed.toList();
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

              // Sort the list by date in descending order
              ticketListData.sort((a, b) {
                DateTime dateA =
                    parseDate(a['date']); // Parse date from mapData
                DateTime dateB = parseDate(b['date']);
                return dateA.compareTo(dateB); // Descending order
              });
            }
          }
          ticketListData = ticketListData.reversed.toList();
        }
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }
  }

  // Function to parse the custom "DD-MM-YYYY" date format
  DateTime parseDate(String dateString) {
    List<String> parts = dateString.split('-'); // Split date string by '-'
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day); // Return DateTime object
  }
}
