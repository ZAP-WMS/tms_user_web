import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/utils/colors.dart';
import 'package:tms_useweb_app/view/image.dart';
import '../provider/filter_provider.dart';
import '../utils/app_dimensions.dart';

// ignore: must_be_immutable
class ReportDetails extends StatefulWidget {
  ReportDetails({
    super.key,
    this.userId,
    required this.ticketList,
    required this.ticketData,
    required this.filterFieldData,
    required this.userRole,
  });
  String? userId;
  List<dynamic> ticketList = [];
  List<dynamic> ticketData = [];
  Map<String, dynamic> filterFieldData;
  List<String>? userRole;
  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  final pattern = RegExp(r',\s*');
  List<dynamic> keys = [
    'date',
    'tickets',
    'building',
    'floor',
    'room',
    'user',
    'asset',
    'serviceProvider',
    'status',
    'work'
  ];
  List<List<String>> rowData = [];

  List<String> assetList = [];
  List<String> floorList = [];
  List<String> buildingList = [];
  List<String> roomList = [];
  List<String> dateList = [];
  List<String> dateClosedList = [];
  List<String> workList = [];
  List<String> serviceList = [];
  List<String> tatList = [];
  List<String> statusList = [];
  List<String> userList = [];
  List<String> remarkList = [];
  List<String> pictureList = [];
  List<String> assignList = [];
  List<String> reviveList = [];
  List<String> ticketNumList = [];

  List<dynamic> ticketList = [];
  List<String> ticketNumberList = [];
  List<String> yearList = [];
  List<String> monthList = [];
  List<String> dayList = [];

  List<String> serviceProvider = [];
  List<dynamic> allData = [];
  String? selectedServiceProvider;
  List<String> allTicketData = [];
  bool isLoading = false;

  String asset = '';
  String building = '';
  String floor = '';
  String remark = '';
  String room = '';
  String work = '';
  String serviceprovider = '';
  List<dynamic> ticketListData = [];
  late final FilterProvider filterProvider;
  List<String> titles = [];
  List<dynamic> message = [];

  @override
  void initState() {
    filterProvider = Provider.of<FilterProvider>(context, listen: false);

    Provider.of<FilterProvider>(context, listen: false).fetchAndFilterData(
        widget.userRole!, widget.userId!, widget.filterFieldData);
    // getdata().whenComplete(() => setState(() {
    //       isLoading = false;
    //     }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    titles = [
      'Status',
      'Ticket No.',
      'Date (Opened)',
      'Date (Closed)',
      'Tat',
      'Work',
      'Building',
      'Floor',
      'Room',
      'Asset',
      'Username',
      'Service Provider',
      'Remark',
      'Image',
    ];
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Report Details',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 141, 36, 41),
        ),
        body:
            Consumer<FilterProvider>(builder: (context, filterProvider, child) {
          final filteredData = filterProvider.filteredData;

          return filterProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filterProvider.filteredData.isEmpty
                  ? const Center(child: Text('No data available'))
                  : GridView.builder(
                      padding:
                          AppDimensions.getPadding(context, percentage: 0.05),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 1.2,
                              childAspectRatio: 1.0,
                              crossAxisCount: 3),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final data = filteredData[index];
                        print('data$data');
                        return Card(
                            margin: AppDimensions.getPadding(context,
                                percentage: 0.005),
                            color: data['status'] == 'Open'
                                ? const Color.fromARGB(255, 240, 210, 247)
                                : AppColors.secondaryColor,
                            elevation: 10,
                            shadowColor: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                // decoration: BoxDecoration(
                                //     border: Border.all(
                                //         color: AppColors.primary Color,
                                //         width: 2.0)),
                                height: 370,
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: titles.length,
                                  itemBuilder: (context, index2) {
                                    print(ticketListData);
                                    String? imagePath = 'No Image Available';
                                    List<String> imageFilePaths = [];

                                    for (int i = 0;
                                        i < data['imageFilePaths'].length;
                                        i++) {
                                      // imageFilePaths =
                                      //     (data['imageFilePaths'] != null &&
                                      //             data['imageFilePaths']
                                      //                 .isNotEmpty)
                                      //         ? data['imageFilePaths']
                                      //         : '';
                                      imagePath = (data['imageFilePaths'] !=
                                                  null &&
                                              data['imageFilePaths'].isNotEmpty)
                                          ? data['imageFilePaths'][i]
                                          : '';
                                      imageFilePaths.add(imagePath!);
                                    }
                                    message = [
                                      data['status'],
                                      data['tickets'],
                                      data['date'],
                                      data['closedDate'] ?? 'NA',
                                      data['tat'].toString(),
                                      data['work'],
                                      data['building'],
                                      data['floor'],
                                      data['room'],
                                      data['asset'],
                                      data['name'],
                                      data['serviceProvider'],
                                      data['remark'],
                                      imagePath!
                                    ];
                                    return ticketCard(titles[index2],
                                        message[index2], imageFilePaths);
                                  },
                                ),
                              ),
                              // ListTile(
                              //   title: Text(data['title'] ?? 'No Title'),
                              //   subtitle: Text(data['status'] ?? 'No Status'),
                              // )
                            ));
                      },
                    );
        }));
  }

  Future<void> getYearList() async {
    // final provider = Provider.of<AllRoomProvider>(context, listen: false);
    // provider.setBuilderList([]);
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('raisedTickets').get();
    if (querySnapshot.docs.isNotEmpty) {
      List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
      yearList = tempData;
    }
    setState(() {});
  }

  Future<void> getMonthList() async {
    // final provider = Provider.of<AllRoomProvider>(context, listen: false);
    // provider.setBuilderList([]);
    for (var i = 0; i < yearList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('raisedTickets')
          .doc(yearList[i])
          .collection('months')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
        monthList = tempData;
      }
      setState(() {});
    }
  }

  Future<void> getDayList() async {
    // final provider = Provider.of<AllRoomProvider>(context, listen: false);
    // provider.setBuilderList([]);
    for (var i = 0; i < yearList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('raisedTickets')
          .doc(yearList[i])
          .collection('months')
          .doc(monthList[i])
          .collection('date')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
        dayList = tempData;
      }
      setState(() {});
    }
  }

  Future<void> getdata() async {
    // List<String> filteredWorkValues =
    //     widget.workFilter!.where((value) => value != null).toList();
    // List<String> filteredStatusValues =
    //     widget.statusFilter!.where((value) => value != null).toList();
    // List<String> filteredAssetValues =
    //     widget.assetFilter!.where((value) => value != null).toList();
    // List<String> filteredBuildingValues =
    //     widget.buildingFilter!.where((value) => value != null).toList();
    // List<String> filteredFloorValues =
    //     widget.floorFilter!.where((value) => value != null).toList();
    // List<String> filteredRoomValues =
    //     widget.roomFilter!.where((value) => value != null).toList();
    // String filteredServiceProviderValues =
    //     widget.serviceProvider!.where((value) => value != null).toList();
    // List<dynamic> filteredTicketNumValues =
    //     widget.ticketFilter!.where((value) => value != null).toList();
    // List<dynamic> filteredUserValues =
    //     widget.userFilter!.where((value) => value != null).toList();
    // List<dynamic> filteredDateValues =
    // widget.dateFilter!.where((value) => value != null).toList();

    try {
      ticketList.clear();
      int currentYear = DateTime.now().year;

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
              // .where('work', isEqualTo: widget.workFilter) // Filter by work
              // .where('status', isEqualTo: widget.statusFilter) // Filter by work
              // .where('serviceProvider',
              //     isEqualTo: widget.serviceProvider) // Filter by work
              // .where('building',
              //     isEqualTo: widget.buildingFilter) // Filter by work
              // .where('floor', isEqualTo: widget.floorFilter) // Filter by work
              // .where('room', isEqualTo: widget.roomFilter) // Filter by work
              // .where('asset', isEqualTo: widget.statusFilter) // Filter by work
              // .where('user', isEqualTo: widget.userFilter) // Filter by work
              // .where('tickets',
              //     isEqualTo: widget.ticketFilter) // Filter by work
              .get();

          temp = ticketQuery.docs.map((e) => e.id).toList();
          // ticketList = ticketList + temp;

          if (temp.isNotEmpty) {
            ticketList.addAll(temp);
            for (int k = 0; k < temp.length; k++) {
              DocumentSnapshot ticketDataQuery = await FirebaseFirestore
                  .instance
                  .collection("raisedTickets")
                  .doc(currentYear.toString())
                  .collection('months')
                  .doc(months[i])
                  .collection('date')
                  .doc(dateList[j])
                  .collection('tickets')
                  .doc(temp[k])
                  .get();
              if (ticketDataQuery.exists) {
                Map<String, dynamic> mapData =
                    ticketDataQuery.data() as Map<String, dynamic>;
                asset = mapData['asset'] ?? "N/A";
                building = mapData['building'] ?? "N/A";
                floor = mapData['floor'] ?? "N/A";
                remark = mapData['remark'] ?? "N/A";
                room = mapData['room'] ?? "N/A";
                work = mapData['work'] ?? "N/A";
                serviceprovider = mapData['serviceProvider'] ?? "";
                widget.ticketData.add(mapData);
                // print('$mapData abc');
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }

    setState(() {});
  }

  List<dynamic> parseTicketListData(String data) {
    // This is just an example. Adjust the parsing logic as needed.
    // Assuming items are separated by commas and image URLs start with 'http'.
    return data.split(',').map((item) {
      item = item.trim();
      return item.startsWith('http') ? item : item;
    }).toList();
  }

  Widget ticketCard(
      String title, String ticketListData, List<String> imageFilePaths) {
    List<dynamic> parsedData = parseTicketListData(ticketListData);
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: parsedData.map((item) {
          if (item is String && item.startsWith('http')) {
            // If it's a URL, display an image
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageScreen(
                                  pageTitle: 'pendingPage',
                                  imageFiles: imageFilePaths,
                                  initialIndex: 0,
                                  ticketId: 'ticketList[0]',
                                )));
                  },
                  child: Row(
                    children: imageFilePaths.map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 4.0),
                        child: ImageNetwork(
                          image: item,
                          height: 50, // Set the height of the image
                          width: 50,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          } else if (item is String) {
            // If it's a text, display it
            return Row(children: [
              SizedBox(
                  width: 110,
                  child: Text(title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(width: 20),
              SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  width: 200,
                  child: Column(
                      children: parsedData.map((item) {
                    if (item is String && item.startsWith('http')) {
                      // If it's a URL, display an image
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Image.network(
                          item,
                          height: 50, // Set the height of the image
                          fit: BoxFit.cover,
                        ),
                      );
                    } else if (item is String) {
                      // If it's a text, display it
                      return Container(
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            item,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      );
                    }
                    return Container();
                    // Return an empty container for unsupported types
                  }).toList()
                      //  [
                      //   Text(
                      //     ticketListData,
                      //     textAlign: TextAlign.justify,
                      //   ),
                      // ],
                      ))
            ]);
          }
          return Container();
          // Return an empty container for unsupported types
        }).toList()

        //  [
        //   SizedBox(
        //     // height: MediaQuery.of(context).size.height,
        //     width: 110,
        //     child: Text(title,
        //         textAlign: TextAlign.start,
        //         style: const TextStyle(fontWeight: FontWeight.bold)),
        //   ),
        //   const SizedBox(width: 20),
        //   Padding(
        //     padding: const EdgeInsets.only(left: 18.0),
        //     child: SizedBox(
        //       // height: MediaQuery.of(context).size.height,
        //       width: 200,
        //       child: Column(
        //           children: parsedData.map((item) {
        //         if (item is String && item.startsWith('http')) {
        //           // If it's a URL, display an image
        //           return Padding(
        //             padding: const EdgeInsets.symmetric(vertical: 4.0),
        //             child: Image.network(
        //               item,
        //               height: 50, // Set the height of the image
        //               fit: BoxFit.cover,
        //             ),
        //           );
        //         } else if (item is String) {
        //           // If it's a text, display it
        //           return Padding(
        //             padding: const EdgeInsets.symmetric(vertical: 4.0),
        //             child: Text(
        //               item,
        //               textAlign: TextAlign.justify,
        //             ),
        //           );
        //         }
        //         return Container();
        //         // Return an empty container for unsupported types
        //       }).toList()
        //           //  [
        //           //   Text(
        //           //     ticketListData,
        //           //     textAlign: TextAlign.justify,
        //           //   ),
        //           // ],
        //           ),
        //     ),
        //   ),

        );
  }

  Future<void> updateTicketStatus(
      String year, String month, String date, String ticketId) async {
    await FirebaseFirestore.instance
        .collection("raisedTickets")
        .doc(year)
        .collection('months')
        .doc(month)
        .collection('date')
        .doc(date)
        .collection('tickets')
        .doc(ticketId)
        .update({'status': 'Open'}).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text('Ticket Revived'),
          ),
        ),
      );
    });
  }
}
