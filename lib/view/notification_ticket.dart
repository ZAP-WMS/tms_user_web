import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/widgets/custom_appbar.dart';
import '../provider/filter_provider.dart';
import '../service/splash_service.dart';
import '../widgets/loading_page.dart';

class NotificationTicket extends StatefulWidget {
  String? userId;
  String? date;
  String? ticketNo;
  NotificationTicket(
      {super.key,
      required this.userId,
      required this.date,
      required this.ticketNo});

  @override
  State<NotificationTicket> createState() => _NotificationTicketState();
}

class _NotificationTicketState extends State<NotificationTicket> {
  List<dynamic> ticketList = [];
  bool _isLoading = true;
  late final FilterProvider filterProvider;
  String? userId;
  final SplashService _splashService = SplashService();
  @override
  void initState() {
    initialize().whenComplete(() {
      filterProvider = Provider.of<FilterProvider>(context, listen: false);
      Provider.of<FilterProvider>(context, listen: false).fetchAllData(userId!);
      getPendingTicket().whenComplete(() async {
        setState(() {
          _isLoading = false;
        });
      });
    });

    super.initState();
  }

  Future<void> initialize() async {
    userId = await _splashService.getUserID();
    setState(() {});
  }

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
  List<dynamic> ticketListData = [];
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
        appBar: CustomAppBar(
            title: 'Tickets Details', isCenter: true, userId: userId ?? ''),
        body: _isLoading
            ? const Center(child: LoadingPage())
            : ticketListData.isNotEmpty
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 2.0),
                    itemCount: ticketListData.length,
                    itemBuilder: (context, index) {
                      return Card(
                          margin: const EdgeInsets.all(10),
                          color: const Color.fromARGB(255, 190, 235, 192),
                          elevation: 10,
                          shadowColor: const Color.fromARGB(255, 172, 231, 174),
                          child: Container(
                              height: 280,
                              padding: const EdgeInsets.all(5),
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
                                                ['serviceProvider'],
                                          ];

                                          return customCard(icons[index2],
                                              titles[index2], message[index2]);
                                        }),
                                  ),
                                ],
                              )));
                    },
                  )
                : Center(
                    child: Text('No Tickets Avilable'),
                  ));
  }

  Future<void> getPendingTicket() async {
    try {
      ticketList.clear();
      QuerySnapshot monthQuery =
          await FirebaseFirestore.instance.collection("raisedTickets").get();
      // List<dynamic> dateList = monthQuery.docs.map((e) => e.id).toList();
      // for (int j = 0; j < dateList.length; j++) {
      List<dynamic> temp = [];
      QuerySnapshot ticketQuery = await FirebaseFirestore.instance
          .collection("raisedTickets")
          .doc(widget.date)
          .collection('tickets')
          .where('user', isEqualTo: widget.userId)
          // .where('status', isEqualTo: 'Open')
          .get();
      temp = ticketQuery.docs.map((e) => e.id).toList();
      // ticketList = ticketList + temp;

      if (temp.isNotEmpty) {
        ticketList.addAll(temp);
        ticketList = ticketList.reversed.toList();
        // for (int k = 0; k < temp.length; k++) {
        DocumentSnapshot ticketDataQuery = await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(widget.date)
            .collection('tickets')
            .doc(widget.ticketNo)
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
          ticketListData = ticketListData.reversed.toList();
          // print('$mapData abc');
        }
        //  }
        // }
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }
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
              SizedBox(width: 10),
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
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
