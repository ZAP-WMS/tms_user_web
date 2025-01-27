import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/utils/app_dimensions.dart';
import 'package:tms_useweb_app/utils/colors.dart';
import 'package:tms_useweb_app/widgets/inside_pageappBar.dart';
import '../../widgets/custom_dropdown.dart';
import '../controller/work_controller.dart';
import '../provider/filter_provider.dart';
import '../provider/raisedata_provider.dart';
import '../utils/auth_services.dart';
import '../widgets/custom_buton.dart';
import '../widgets/custom_text_fom.dart';
import 'package:http/http.dart' as http;

class RaiseTicket extends StatefulWidget {
  String userID;
  RaiseTicket({super.key, required this.userID});

  @override
  State<RaiseTicket> createState() => _RaiseTicketState();
}

class _RaiseTicketState extends State<RaiseTicket> {
  TextEditingController remarkController = TextEditingController();
  AuthService authService = AuthService();
  WorkController workController = WorkController();
  late final FilterProvider filterProvider;
  late final RaiseDataProvider raiseDataProvider;

  String serviceProviders = 'N/A';
  String? serviceProvidersId;
  List<String> workOptions = [];
  List<String> buildingOptions = [];
  List<String> floorOptions = [];
  List<String> roomOptions = [];
  List<String> assetOptions = [];

  String? selectedServiceProvider;
  String? _selectedWork;
  String? _selectedBuilding;
  String? _selectedFloor;
  String? _selectedRoom;
  String? _selectedAsset;
  String ticketID = '';
  String? selectedBuildingNo = '';
  String? selectedFloorNo = '';

  FilePickerResult? result;
  List<String>? Imagenames = [];
  List<File>? filepath = [];
  List<String> images = [];
  List<Uint8List> imageBytesList = []; // List to store image data (bytes)
  ScrollController scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    filterProvider = Provider.of<FilterProvider>(context, listen: false);
    raiseDataProvider = Provider.of<RaiseDataProvider>(context, listen: false);
    raiseDataProvider.fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: commonAppBar(title: 'Raised Ticket', onBackPressed: () {}),
        body: Consumer<RaiseDataProvider>(builder: (context, provider, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Material(
                elevation: 20.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: AppDimensions.getWidth(context, percentage: 0.6),
                  height: AppDimensions.getHeight(context, percentage: 0.5),
                  decoration: BoxDecoration(
                      boxShadow: const [],
                      border: Border.all(color: AppColors.textWhite),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdown(
                              label: 'Select Work',
                              value: provider.selectedWork, //
                              onChanged: (value) {
                                _selectedWork = value;
                                provider.setSelectedWork(value.toString());

                                filterProvider.fetchFcmID(
                                    provider.selectedWork.toString());
                                provider.resetSpecificSelection();
                              },
                              items: provider.workData.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                            ),
                            CustomDropdown(
                              label: 'Building',
                              value: provider.selectedBuilding,
                              onChanged: (value) {
                                floorOptions.clear();
                                selectedBuildingNo = value;
                                _selectedBuilding = value;
                                provider.setSelectedBuilding(
                                    selectedBuildingNo.toString());
                                provider.getFloor();
                              },
                              items:
                                  provider.buildingOption.map((String option) {
                                return DropdownMenuItem<String>(
                                    value: option, child: Text(option));
                              }).toList(),
                            ),
                            CustomDropdown(
                              label: 'Floor',
                              value: provider.selectedFloor,
                              onChanged: (value) async {
                                _selectedFloor = value;
                                provider.setSelectedFloor(
                                    _selectedFloor.toString());
                                provider.getRoom();
                              },
                              items: provider.floorOption.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                            ),
                            CustomDropdown(
                              label: 'Room',
                              value: provider.roomOption
                                      .contains(provider.selectedRoom)
                                  ? provider.selectedRoom
                                  : null,
                              onChanged: (value) async {
                                roomOptions.clear;
                                _selectedRoom = value;
                                provider
                                    .setSelectedRoom(_selectedRoom.toString());
                                provider.getAsset(_selectedWork.toString(),
                                    _selectedRoom.toString());
                              },
                              items: provider.roomOption.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                            ),
                            CustomDropdown(
                              label: 'Asset',
                              value: provider.assetOption
                                      .contains(provider.selectedAsset)
                                  ? provider.selectedAsset
                                  : null,
                              onChanged: (value) {
                                _selectedAsset = value;
                                provider.setSelectedAsset(
                                    _selectedAsset.toString());
                              },
                              items: provider.assetOption.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                            ),
                            CustomTextFormField(
                              width: AppDimensions.getWidth(context,
                                  percentage: 0.2),
                              controller: remarkController,
                              label: 'Remark',
                              hintText: 'Remarks',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: AppDimensions.getWidth(context,
                              percentage: 0.02)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (Imagenames != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(
                                    child: Text('Selected file:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(
                                    height: AppDimensions.getHeight(context,
                                        percentage: 0.3),
                                    width: 500,
                                    child: GridView.builder(
                                        itemCount: imageBytesList.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5,
                                          childAspectRatio: 1.3,
                                        ),
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {},
                                            child: Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                margin: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.blue),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Image.memory(
                                                  imageBytesList[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                          SizedBox(
                              height: AppDimensions.getHeight(context,
                                  percentage: 0.02)),
                          Row(
                            children: [
                              CustomButton(
                                  width: AppDimensions.getWidth(context,
                                      percentage: 0.08),
                                  text: 'Pick Image',
                                  onPressed: () async {
                                    // Open file picker and allow multiple files
                                    result =
                                        await FilePicker.platform.pickFiles(
                                      withData: true,
                                      type: FileType.any,
                                      allowMultiple: true,
                                    );

                                    if (result == null) {
                                      print('No file selected');
                                    } else {
                                      result!.files.forEach((element) {
                                        Imagenames!.add(element.name);

                                        if (result!.files.isNotEmpty) {
                                          // Convert PlatformFile to html.File (for web)
                                          final htmlFile = File(
                                              [element.bytes!], element.name);

                                          // Now you can work with html.File, such as adding it to a list
                                          filepath!.add(htmlFile);
                                          Uint8List fileBytes = element.bytes!;
                                          imageBytesList.add(fileBytes);
                                        } else {
                                          print(
                                              "No data available for ${element.name}");
                                        }
                                        setState(() {});
                                      });
                                    }
                                  }),
                              SizedBox(
                                width: AppDimensions.getWidth(context,
                                    percentage: 0.02),
                              ),
                              CustomButton(
                                  width: AppDimensions.getWidth(context,
                                      percentage: 0.08),
                                  text: 'Save',
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) =>
                                            const CupertinoAlertDialog(
                                          content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: const [
                                              SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Color.fromARGB(
                                                              255,
                                                              151,
                                                              64,
                                                              69)),
                                                ),
                                              ),
                                              Text(
                                                'Saving...',
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 151, 64, 69),
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                      await generateTicketID();
                                      await fetchServiceProvider()
                                          .whenComplete(() async {
                                        await uploadFile(ticketID);
                                        await storeRaisedTicket(ticketID)
                                            .whenComplete(() async {
                                          sendNotificationViaGet(
                                              'http://localhost:300/not',
                                              filterProvider.tokenId.toString(),
                                              'hii abdul',
                                              'api is working');

                                          provider.resetSelections();
                                          remarkController.clear();
                                          images.clear();
                                          Imagenames!.clear();

                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor:
                                                      AppColors.primaryColor,
                                                  content: Text(
                                                      'Your ticket $ticketID has been raised successfully!!!')));
                                        });
                                      });
                                    }
                                  })
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }));
  }

  Future<String> generateTicketID() async {
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    int currentYear = DateTime.now().year;

    String currentMonth = DateFormat('MMM').format(DateTime.now());

    QuerySnapshot doc = await FirebaseFirestore.instance
        .collection("raisedTickets")
        // .doc(currentYear.toString())
        // .collection('months')
        // .doc(currentMonth.toString())
        // .collection('date')
        .doc(date)
        .collection('tickets')
        .get();

    int lastTicketID = 1;
    if (doc.docs.isNotEmpty) {
      lastTicketID = doc.docs.length + 1;
    }

    DateTime now = DateTime.now();

    String formattedDate = "${now.year.toString().padLeft(4, '0')}"
        "${now.month.toString().padLeft(2, '0')}"
        "${now.day.toString().padLeft(2, '0')}";

    String formattedTicketNumber = lastTicketID.toString().padLeft(2, '0');

    // Generate the next ticket ID
    // int nextTicketID = lastTicketID + 1;
    // String ticketID = '#$nextTicketID';

    // int timestamp = DateTime.now().millisecondsSinceEpoch;
    // int random = Random().nextInt(9999);
    ticketID = "$formattedDate.$formattedTicketNumber";
    return ticketID;
  }

  Future<void> fetchServiceProvider() async {
    List<String> tempData = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('members')
        .where('role', arrayContains: _selectedWork)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      tempData = querySnapshot.docs.map((e) => e.id).toList();
      serviceProviders = tempData[0];

      try {
        // Fetch the document from Firestore
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('members')
            .doc(serviceProviders)
            .get();

        if (documentSnapshot.exists) {
          // Extract data from the document
          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;

          if (data != null) {
            // Access specific fields from the data map
            serviceProvidersId = data['userId'];
            print('Name: $serviceProvidersId');
            // Handle other fields as needed
          } else {
            print('Document data is null');
          }
        } else {
          print('Document does not exist');
        }
      } catch (e) {
        print('Error fetching document: $e');
      }
    }

    setState(() {});
  }

  Future<void> uploadFile(String id) async {
    try {
      String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      int currentYear = DateTime.now().year;
      String currentMonth = DateFormat('MMM').format(DateTime.now());

      // Ensure filepath is not null or empty
      if (filepath != null && filepath!.isNotEmpty) {
        print(filepath);
        // List<String> url = []; // List to store file URLs

        if (result != null && result!.files.isNotEmpty) {
          print(result!.files);

          // Loop through each file in result.files and upload it
          for (int i = 0; i < result!.files.length; i++) {
            PlatformFile file = result!.files[i];

            if (file.bytes == null) {
              throw Exception('File bytes are null');
            }

            Uint8List fileBytes = file.bytes!;

            // Upload the file to Firebase Storage
            final taskSnapshot = await FirebaseStorage.instance
                .ref('Images/')
                .child(id)
                .child(file.name)
                .putData(fileBytes);

            String downloadUrl = await taskSnapshot.ref.getDownloadURL();

            // Add the URL to the list of URLs
            images.add(downloadUrl);
          }

          // // Update Firestore with the list of image file URLs
          // await FirebaseFirestore.instance
          //     .collection("raisedTickets")
          //     .doc(currentYear.toString())
          //     .collection('months')
          //     .doc(currentMonth.toString())
          //     .collection('date')
          //     .doc(date)
          //     .collection('tickets')
          //     .doc(id)
          //     .update({
          //   "imageFilePaths": [
          //     ' ...url'
          //   ], // Store the URLs in the Firestore document
          // });

          print("Firestore update complete.");
        } else {
          throw Exception('No files selected.');
        }
      } else {
        throw Exception('No files to upload.');
      }
    } on FirebaseException catch (e) {
      print('Failed to upload file: $e');
    } catch (e) {
      print('Error: $e');
    }
    // Future<void> uploadFile(String id) async {
    //   try {
    //     String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    //     int currentYear = DateTime.now().year;

    //     String currentMonth = DateFormat('MMM').format(DateTime.now());

    //     if (filepath!.isNotEmpty) {
    //       print(filepath);
    //       List<String> url = [];

    //       if (result!.files.isNotEmpty) {
    //         print(result!.files);
    //         for (int i = 0; i < result!.files.length; i++) {
    //           PlatformFile file = result!.files[i];

    //           Uint8List fileBytes = file.bytes!;

    //           // Upload to Firebase Storage
    //           final taskSnapshot = await FirebaseStorage.instance
    //               .ref('Images/')
    //               .child(id)
    //               .child(file.name)
    //               .putData(fileBytes);

    //           print('Upload complete: ${taskSnapshot.ref.fullPath}');
    //         }
    //       }

    //       await FirebaseFirestore.instance
    //           .collection("raisedTickets")
    //           .doc(currentYear.toString())
    //           .collection('months')
    //           .doc(currentMonth.toString())
    //           .collection('date')
    //           .doc(date)
    //           .collection('tickets')
    //           .doc(id)
    //           .update({
    //         "imageFilePaths": url,
    //       });
    //     } else {
    //       throw Exception('File bytes are null');
    //     }
    //   } on FirebaseException catch (e) {
    //     print('Failed to upload PDF file: $e');
    //   }
    // }
  }

  Future<void> storeRaisedTicket(String ticketID) async {
    String userName = await fetchName(widget.userID);
    // fetchServiceProvider();
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    int currentYear = DateTime.now().year;

    String currentMonth = DateFormat('MMM').format(DateTime.now());

    // List<String> imageFilePaths =
    //     await _saveImagesToPersistentStorage(Imagenames!);

    await FirebaseFirestore.instance
        .collection("raisedTickets")
        // .doc(currentYear.toString())
        // .collection('months')
        // .doc(currentMonth.toString())
        // .collection('date')
        .doc(date)
        .collection('tickets')
        .doc(ticketID)
        .set({
      "month": currentMonth,
      "year": currentYear,
      "work": _selectedWork,
      "building": _selectedBuilding,
      "floor": _selectedFloor,
      "room": _selectedRoom,
      "asset": _selectedAsset,
      "remark": remarkController.text,
      "serviceProvider": serviceProviders,
      "serviceProviderId": serviceProvidersId,
      "imageFilePaths": images,
      "date": date,
      "user": widget.userID,
      'status': 'Open',
      "tickets": ticketID,
      "isSeen": true,
      "name": userName
    }).whenComplete(() async {
      await FirebaseFirestore.instance
          .collection("UserNotification")
          // .doc(currentYear.toString())
          // .collection('months')
          // .doc(currentMonth.toString())
          // .collection('date')
          .doc(date)
          .collection('tickets')
          .doc(ticketID)
          .set({
        " month": currentMonth,
        "year": currentYear,
        "work": _selectedWork,
        "building": _selectedBuilding,
        "floor": _selectedFloor,
        "room": _selectedRoom,
        "asset": _selectedAsset,
        "remark": remarkController.text,
        "serviceProvider": serviceProviders,
        "serviceProviderId": serviceProvidersId,
        "imageFilePaths": images,
        "date": date,
        "user": widget.userID,
        'status': 'Open',
        "tickets": ticketID,
        "isSeen": true,
        "name": userName
      });
    });
    await addNotification(
        widget.userID,
        filterProvider.serviceProviderId.toString(),
        userName,
        filterProvider.serviceProviderName.toString(),
        ticketID,
        DateTime.now().toString());
    print("Data Stored Successfully");

    await FirebaseFirestore.instance
        .collection("UserNotification")
        .doc(date)
        .set({
      "raisedTickets": date,
    });
    await FirebaseFirestore.instance.collection("raisedTickets").doc(date).set({
      "raisedTickets": date,
    });
    // await FirebaseFirestore.instance
    //     .collection("raisedTickets")
    //     .doc(date)
    //     .collection('tickets')
    //     .doc(ticketID.toString())
    //     .set({
    //   "months": currentMonth,
    // });
  }

  Future<String> fetchName(String userID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("members")
        .where('userId', isEqualTo: userID)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List<dynamic> tempData = querySnapshot.docs.map((e) => e.id).toList();
      return tempData[0];
    } else {
      return '';
    }
  }

  // Future<List<String>> _saveImagesToPersistentStorage(
  //     List<String> imagePaths) async {
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   String appDocPath = appDocDir.path;

  //   List<String> savedPaths = [];
  //   for (String path in imagePaths) {
  //     File tempfile = File(path);
  //     String fileName = path.split('/').last;
  //     String newPath = '$appDocPath/$fileName';
  //     await tempfile.copy(newPath);
  //     savedPaths.add(newPath);
  //   }
  //   return savedPaths;
  // }

  Future<void> sendNotificationViaGet(
      String url, String token, String title, String message) async {
    // Define the query parameters
    print('token$token');
    final queryParameters = {
      'token': token,
      'title': title,
      'message': message,
    };

    // Construct the URI with query parameters
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    print(uri);

    try {
      // Perform the GET request with headers
      final response = await http.get(uri);
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

  Future<void> addNotification(String userId, String serviceId, String userName,
      String serviceName, String ticketId, String timeStamp) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Generate the timestamp on the client side
    DateTime now = DateTime.now();
    Timestamp timestamp = Timestamp.fromDate(now);

    // Define the new notification data
    Map<String, dynamic> newNotification = {
      'userID': userId,
      'serviceProviderId': serviceId,
      'isServiceProviderSeen': true,
      'userName': userName,
      'serviceProviderName': serviceName,
      'TicketId': ticketId,
      'timestamp': timestamp,
    };

    // Reference to the Firestore document
    DocumentReference userDoc =
        firestore.collection('notifications').doc(serviceId);

    // Add the new notification to the array
    try {
      await userDoc.set({
        'notifications': FieldValue.arrayUnion([newNotification])
      }, SetOptions(merge: true));
      print('Notification added successfully');
    } catch (e) {
      print('Failed to add notification: $e');
    }
  }
}
