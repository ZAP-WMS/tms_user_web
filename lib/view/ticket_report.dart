import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/utils/app_dimensions.dart';
import 'package:tms_useweb_app/utils/colors.dart';
import 'package:tms_useweb_app/view/display_report.dart';
import 'package:tms_useweb_app/widgets/inside_pageappBar.dart';
import '../provider/getReport_provider.dart';
import '../service/splash_service.dart';
import '../utils/text_styles.dart';
import '../widgets/custom_buton.dart';

class TicketReport extends StatefulWidget {
  TicketReport({super.key, required this.userID});
  String userID;
  @override
  State<TicketReport> createState() => _TicketReportState();
}

class _TicketReportState extends State<TicketReport> {
  TextEditingController assetController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController workController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController buildingController = TextEditingController();
  TextEditingController ticketController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  List<String> buildingList = [];
  List<dynamic> filterData = [];
  List<String> floorList = [];
  List<String> roomList = [];
  List<String> assetList = [];
  List<String> userList = [];
  List<String> allTicketList = [];
  List<String> workList = [];
  List<String> uniqueFloorList = [];
  String? selectedAsset;
  String? selectedFloor;
  String? selectedRoom;
  String selectedStartDate = '';
  String selectedEndDate = '';
  String? selectedUser;
  String? selectedTicket;
  String? selectedbuilding;
  String? selectedWork;
  String? selectedStatus;

  List<String> floorNumberList = [];
  List<dynamic> allData = [];
  List<dynamic> serviceProviderList = [];
  String? selectedTicketNumber;
  List<String> allDateData = [];
  List<String> allTicketData = [];
  List<String> allAssetData = [];
  List<String> allUserData = [];
  List<String> buildingNumberList = [];
  List<String> allFloorData = [];
  List<String> allWorkData = [];
  List<String> allRoomData = [];
  List<String> allStatusData = ['Open', 'Close'];
  List<dynamic> ticketList = [];
  List<String> serviceProvider = [];
  List<String>? selectedSPList = [];

  String? selectedServiceProvider;
  List<String> roomNumberList = [];
  List<String> ticketNumberList = [];
  bool isLoading = true;
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime(2020, 01, 01),
    end: DateTime(2025, 01, 01),
  );

  DateTime rangeStartDate = DateTime.now();
  DateTime? rangeEndDate = DateTime.now();
  List<String>? userRole = [];
  final SplashService _splashService = SplashService();
  late ReportProvider dataProvider = ReportProvider();
  // String? userId;
  @override
  void initState() {
    dataProvider = Provider.of<ReportProvider>(context, listen: false);
    dataProvider.resetSelections();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserRole();
      // Delayed execution of async methods after initial build
      initialize();
    });

    // initialize();

    super.initState();
  }

  TextEditingController ticketnumberController = TextEditingController();
  TextEditingController serviceProviderController = TextEditingController();

  Future initialize() async {
    await dataProvider.fetchFloorNumbers();
    userRole!.isEmpty
        ? await dataProvider.fetchTicketNumbers(widget.userID)
        : await dataProvider.fetchServiceProviderTicketNumbers(widget.userID);
    await dataProvider.fetchBuildingNumbers();
    await dataProvider.fetchRoomNumbers();
    await dataProvider.fetchWorkList();
    await dataProvider.fetchServiceProvider();
    await dataProvider.fetchUser();
    await dataProvider.fetchAssets();
  }

  getUserRole() async {
    userRole = await _splashService.getUserName(widget.userID);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: commonAppBar(
          title: 'Ticket Report',
          onBackPressed: () {},
        ),
        body: Consumer<ReportProvider>(
          builder: (context, provider, child) {
            return Container(
              margin: const EdgeInsets.only(top: 10),
              padding: AppDimensions.getPadding(context, percentage: 0.05),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryColor)),
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 60,
                        child: TextButton(
                            onPressed: () {
                              pickDateRange();
                              setState(() {});
                            },
                            child: Row(
                              spacing: 10.0,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),
                                Text('Choose Date :',
                                    style: AppTextStyles.boldBlackColor),
                                Text(
                                  selectedStartDate.isNotEmpty
                                      ? " $selectedStartDate     TO     $selectedEndDate  "
                                      : '',
                                  style: AppTextStyles.boldBlackColor,
                                ),
                                const Spacer(),
                                IconButton(
                                  alignment: Alignment.bottomRight,
                                  iconSize: 23,
                                  icon: const Icon(Icons.cancel,
                                      color: AppColors.dartGreyColor),
                                  onPressed: () {
                                    selectedStartDate = '';
                                    selectedEndDate = '';
                                    setState(() {});
                                  },
                                ),
                              ],
                            )
                            //  Align(
                            //   alignment: Alignment.center,
                            //   child: RichText(
                            //       textAlign: TextAlign.center,
                            //       text: TextSpan(
                            //           text: 'Search Date',
                            //           style: AppTextStyles.boldBlackColor,
                            //           children: [
                            //             TextSpan(
                            //                 text: selectedStartDate.isNotEmpty
                            //                     ? " $selectedStartDate     TO     $selectedEndDate  "
                            //                     : '',
                            //                 style: AppTextStyles.boldBlackColor),
                            //           ])),
                            // ),
                            ),
                      )),
                  Row(
                    children: [
                      customDropDown(
                        customDropDownList: ['Open', 'Close'],
                        hintText: 'Search Status',
                        index: 0,
                        selectedValue: provider.selectedStatus,
                        onChanged: (value) {
                          provider.status(value.toString());
                        },
                        clearAction: () {
                          provider.clearSelection('status');
                        },
                        searchController: statusController,
                      ),
                      customDropDown(
                        customDropDownList: provider.floorNumberList,
                        hintText: 'Search Floor',
                        index: 0,
                        selectedValue: provider.selectedFloor,
                        onChanged: (value) {
                          provider.floor(value.toString());
                        },
                        clearAction: () {
                          provider.clearSelection('floor');
                        },
                        searchController: floorController,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      customDropDown(
                        customDropDownList: provider.ticketNumberList,
                        hintText: 'Select Ticket',
                        index: 0,
                        selectedValue: provider.selectedTicket,
                        onChanged: (value) {
                          provider.ticket(value.toString());
                        },
                        clearAction: () {
                          provider.clearSelection('ticket');
                        },
                        searchController: ticketController,
                      ),
                      customDropDown(
                        customDropDownList: provider.roomNumberList,
                        hintText: 'Search Room',
                        index: 0,
                        selectedValue: provider.selectedRoom,
                        onChanged: (value) {
                          provider.room(value.toString());
                        },
                        clearAction: () {
                          provider.clearSelection('room');
                        },
                        searchController: roomController,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      customDropDown(
                        customDropDownList: provider.workNumberList,
                        hintText: 'Select Work',
                        index: 0,
                        selectedValue: provider.selectedWork,
                        onChanged: (value) {
                          provider.work(value.toString());
                        },
                        clearAction: () {
                          provider.clearSelection('work');
                        },
                        searchController: workController,
                      ),
                      customDropDown(
                        customDropDownList: provider.assetNumberList,
                        hintText: 'Search Asset',
                        index: 0,
                        selectedValue: provider.selectedAsset,
                        onChanged: (value) {
                          provider.asset(value.toString());
                        },
                        clearAction: () {
                          provider.clearSelection('asset');
                        },
                        searchController: assetController,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      customDropDown(
                        customDropDownList: provider.buildingNumberList,
                        hintText: 'Search Building',
                        index: 0,
                        selectedValue: provider.selectedBuilding,
                        onChanged: (value) {
                          provider.building(value.toString());
                        },
                        clearAction: () {
                          provider.clearSelection('building');
                        },
                        searchController: buildingController,
                      ),
                      customDropDown(
                        customDropDownList: userRole!.isEmpty
                            ? provider.serviceProviders
                            : provider.users,
                        hintText: userRole!.isEmpty
                            ? 'Search Service Provider'
                            : 'Search Users',
                        index: 0,
                        selectedValue: userRole!.isEmpty
                            ? provider.selectedService
                            : provider.selectUser,
                        onChanged: (value) {
                          userRole!.isEmpty
                              ? provider.serviceProvider(value.toString())
                              : provider.usersName(value.toString());
                        },
                        clearAction: () {
                          userRole!.isEmpty
                              ? provider.clearSelection('serviceProvider')
                              : provider.clearSelection('users');
                        },
                        searchController: serviceProviderController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: 'Get Report',
                        width: 150,
                        onPressed: () {
                          // showSavingDialog(context, 'Fetching...');
                          Map<String, dynamic> selectedItemsMap = {
                            'selectedStatus': provider.selectedStatus,
                            'selectedTicket': provider.selectedTicket,
                            'selectedWork': provider.selectedWork,
                            'selectedBuilding': provider.selectedBuilding,
                            'selectedFloor': provider.selectedFloor,
                            'selectedRoom': provider.selectedRoom,
                            'selectedAsset': provider.selectedAsset,
                            'selectedServiceProvider': provider.selectedService,
                            'selectedUser': provider.selectUser,
                            'selectedStartDate': selectedStartDate,
                            'selectedEndDate': selectedEndDate,
                          };

                          bool atLeastOneAvailable =
                              selectedItemsMap.values.any((value) {
                            if (value == null) {
                              return false; // Check if the value is null
                            }
                            if (value is String && value.isEmpty) {
                              return false; // Check if the value is an empty string
                            }
                            return true; // Return true if the value is not null and not empty
                          });

                          if (atLeastOneAvailable) {
                            dataProvider.resetSelections();
                            selectedStartDate = '';
                            selectedEndDate = '';
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Align(
                                    alignment: Alignment
                                        .center, // Align the dialog content to the right
                                    child: Container(
                                        width: AppDimensions.getWidth(context,
                                            percentage: 0.9),
                                        padding: const EdgeInsets.all(16.0),
                                        child: ReportDetails(
                                            userId: widget.userID,
                                            ticketList: ticketList,
                                            ticketData: filterData,
                                            filterFieldData: selectedItemsMap,
                                            userRole: userRole!)),
                                  ),
                                );
                                // ReportDetails(
                                //   ticketList: ['u'],
                                //   ticketData: ['u'],
                                //   filterFieldData: {},
                                //   userRole: ['7'],
                                // );
                                //  AlertDialog(
                                //   title: Text('Ticket Raised'),
                                //   content: Text(
                                //       'Your ticket has been successfully raised!'),
                                //   actions: [
                                //     TextButton(
                                //       onPressed: () => Navigator.pop(context),
                                //       child: Text('Close'),
                                //     ),
                                //   ],
                                // );
                              },
                            );
                          } else {
                            Navigator.pop(context);
                            popupAlertmessage('Please select any filter');
                          }
                          //});
                        },
                        textColor: AppColors.backgroundColor,
                      ),
                      const SizedBox(width: 20),
                      CustomButton(
                          text: 'Clear',
                          width: 150,
                          onPressed: () {
                            provider.resetSelections();
                            selectedStartDate = '';
                            selectedEndDate = '';
                          })
                    ],
                  ),
                ],
              ),
            );
          },
        ));
  }

  void popupAlertmessage(String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              content: Text(
                msg,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
          );
        });
  }

  Widget customDropDown({
    // required String title,
    required List<String> customDropDownList,
    required String hintText,
    required int index,
    required String? selectedValue,
    required Function? clearAction,
    required ValueChanged<String?> onChanged,
    required TextEditingController searchController,
  }) {
    return Expanded(
      child: Padding(
        padding: AppDimensions.getPadding(context, percentage: 0.002),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint:
                            Text(hintText, style: AppTextStyles.boldBlackColor),
                        items: customDropDownList
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: AppTextStyles.boldBlackColor,
                                  ),
                                ))
                            .toList(),
                        value: selectedValue,
                        onChanged: onChanged,
                        buttonStyleData: const ButtonStyleData(
                          decoration: BoxDecoration(),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          height: 50,
                          width: double.infinity,
                        ),
                        dropdownStyleData: const DropdownStyleData(
                          maxHeight: 200,
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                        ),
                        dropdownSearchData: DropdownSearchData(
                          searchController: searchController,
                          searchInnerWidgetHeight: 50,
                          searchInnerWidget: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextFormField(
                              controller: searchController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                hintText: hintText,
                                hintStyle: const TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) {
                            return item.value.toString().contains(searchValue);
                          },
                        ),
                        onMenuStateChange: (isOpen) {
                          if (!isOpen) {
                            searchController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        clearAction?.call();
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      // initialEntryMode: DatePickerEntryMode.input,
    );
    if (newDateRange == null) return;
    setState(() {
      dateRange = newDateRange;
      rangeStartDate = dateRange.start;
      rangeEndDate = dateRange.end;
      selectedStartDate = DateFormat('dd-MM-yyyy').format(rangeStartDate);
      selectedEndDate = DateFormat('dd-MM-yyyy').format(rangeEndDate!);
    });
  }

  // Future<void> filterTickets(String userID) async {
  //   // print('before $selectedUser');
  //   // selectedUser = selectedUser.toString().split(' ')[2];
  //   // print('selectedUse123r $selectedUser');
  //   try {
  //     // filterData.clear();
  //     // ticketList.clear();
  //     int currentYear = DateTime.now().year;

  //     QuerySnapshot monthQuery =
  //         await FirebaseFirestore.instance.collection("raisedTickets").get();
  //     List<dynamic> dateList = monthQuery.docs.map((e) => e.id).toList();
  //     for (int i = 0; i < dateList.length; i++) {
  //       if (selectedStartDate.isNotEmpty && selectedEndDate.isNotEmpty) {
  //         for (DateTime date = dateRange.start;
  //             date.isBefore(dateRange.end.add(Duration(days: 1)));
  //             date = date.add(Duration(days: 1))) {
  //           String currentDate = DateFormat('dd-MM-yyyy').format(date);

  //           List<dynamic> temp = [];
  //           QuerySnapshot ticketQuery = await FirebaseFirestore.instance
  //               .collection("raisedTickets")
  //               .doc(currentDate)
  //               .collection('tickets')
  //               .where('user', isEqualTo: widget.userID)
  //               .where('date', isEqualTo: currentDate.trim())
  //               // .where('date', isLessThanOrEqualTo: selectedEndDate.trim())
  //               .get();

  //           temp = ticketQuery.docs.map((e) => e.id).toList();
  //           // ticketList = ticketList + temp;

  //           if (temp.isNotEmpty) {
  //             ticketList = ticketList + temp;
  //             for (int k = 0; k < temp.length; k++) {
  //               DocumentSnapshot ticketDataQuery = await FirebaseFirestore
  //                   .instance
  //                   .collection("raisedTickets")
  //                   .doc(currentDate)
  //                   .collection('tickets')
  //                   .doc(temp[k])
  //                   .get();
  //               if (ticketDataQuery.exists) {
  //                 Map<String, dynamic> mapData =
  //                     ticketDataQuery.data() as Map<String, dynamic>;
  //                 filterData.add(mapData);
  //                 print('$mapData filtered data');
  //               }
  //             }
  //           }
  //         }
  //       } else {
  //         QuerySnapshot dateQuery = await FirebaseFirestore.instance
  //             .collection("raisedTickets")
  //             .get();
  //         List<dynamic> dateList = dateQuery.docs.map((e) => e.id).toList();
  //         for (int j = 0; j < dateList.length; j++) {
  //           List<dynamic> temp = [];
  //           Query query = FirebaseFirestore.instance
  //               .collection("raisedTickets")
  //               .doc(dateList[j])
  //               .collection('tickets');
  //           if (selectedStatus != null) {
  //             query = query.where('status', isEqualTo: selectedStatus);
  //           }
  //           if (selectedFloor != null) {
  //             query = query.where('floor', isEqualTo: selectedFloor);
  //           }
  //           if (selectedTicket != null) {
  //             query = query.where('tickets', isEqualTo: selectedTicket);
  //           }
  //           if (selectedRoom != null) {
  //             query = query.where('room', isEqualTo: selectedRoom);
  //           }
  //           if (selectedWork != null) {
  //             query = query.where('work', isEqualTo: selectedWork);
  //           }
  //           if (selectedAsset != null) {
  //             query = query.where('asset', isEqualTo: selectedAsset);
  //           }
  //           if (selectedbuilding != null) {
  //             query = query.where('building', isEqualTo: selectedbuilding);
  //           }
  //           if (selectedServiceProvider != null) {
  //             query = query.where('serviceProvider',
  //                 isEqualTo: selectedServiceProvider);
  //           }
  //           QuerySnapshot ticketQuery = await query.get();
  //           //await FirebaseFirestore.instance
  //           //     .collection("raisedTickets")
  //           //     .doc(currentYear.toString())
  //           //     .collection('months')
  //           //     .doc(months[i])
  //           //     .collection('date')
  //           //     .doc(dateList[j])
  //           //     .collection('tickets')
  //           //     .where('work', isEqualTo: selectedWork) // Filter by work
  //           //     .where('status', isEqualTo: selectedStatus) // Filter by work
  //           //     .where('serviceProvider',
  //           //         isEqualTo: selectedServiceProvider) // Filter by work
  //           //     .where('building',
  //           //         isEqualTo: selectedbuilding) // Filter by work
  //           //     .where('floor', isEqualTo: selectedFloor) // Filter by work
  //           //     .where('room', isEqualTo: selectedRoom) // Filter by work
  //           //     .where('asset', isEqualTo: selectedAsset) // Filter by work
  //           //     .where('tickets', isEqualTo: selectedTicket) // Filter by work
  //           //     .get();

  //           temp = ticketQuery.docs.map((e) => e.id).toList();
  //           // ticketList = ticketList + temp;
  //           print('Temp String $temp');

  //           if (temp.isNotEmpty) {
  //             ticketList = ticketList + temp;
  //             for (int k = 0; k < temp.length; k++) {
  //               DocumentSnapshot ticketDataQuery = await FirebaseFirestore
  //                   .instance
  //                   .collection("raisedTickets")
  //                   .doc(dateList[j])
  //                   .collection('tickets')
  //                   .doc(temp[k])
  //                   .get();
  //               if (ticketDataQuery.exists) {
  //                 Map<String, dynamic> mapData =
  //                     ticketDataQuery.data() as Map<String, dynamic>;

  //                 filterData.add(mapData);
  //                 print('$mapData abc');
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Error Fetching tickets: $e");
  //   }
  // }

  DateTime parseDate(String ticketId) {
    int year = int.parse(ticketId.substring(0, 4));
    int month = int.parse(ticketId.substring(4, 6));
    int day = int.parse(ticketId.substring(0, 4));
    return DateTime(year, month, day);
  }
}
