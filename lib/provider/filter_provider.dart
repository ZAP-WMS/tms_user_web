import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FilterProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _filteredData = [];
  List<Map<String, dynamic>> _openData = [];
  List<Map<String, dynamic>> _closeData = [];
  List<Map<String, dynamic>> _pendingData = [];
  List<Map<String, dynamic>> _servicependingData = [];
  final List<Map<String, dynamic>> _isUserSeen = [];
  final List<Map<String, dynamic>> _isServiceProviderSeen = [];
  List<String> _ticketId = [];
  String? _tokenData;
  String? _serviceProviderName;
  String? _serviceProviderId;
  int _closeDataLength = 0;
  List<dynamic> _notifications = [];

  List<Map<String, dynamic>> get filteredData => _filteredData;
  List<Map<String, dynamic>> get openData => _openData;
  List<Map<String, dynamic>> get closeData => _closeData;
  List<Map<String, dynamic>> get pendingData => _pendingData;
  List<Map<String, dynamic>> get servicependingData => _servicependingData;
  List<Map<String, dynamic>> get userSeen => _isUserSeen;
  List<Map<String, dynamic>> get serviceProviderSeen => _isServiceProviderSeen;
  List<dynamic> get notifications => _notifications;

  List<String> get ticketId => _ticketId;
  String? get tokenId => _tokenData;
  String? get serviceProviderName => _serviceProviderName;
  String? get serviceProviderId => _serviceProviderId;
  int get closeticketLength => _closeDataLength;
  bool _isLoading = true;
  bool _isopenLoading = true;
  bool _isserviceLoading = true;

  bool get isLoading => _isLoading;
  bool get openLoading => _isopenLoading;
  bool get serviceLoading => _isserviceLoading;
  // bool get isLoading => _isLoading;

  set notifications(List<dynamic> value) {
    _notifications = value;
    notifyListeners(); // Notify listeners of the change
  }

  Future<void> fetchAndFilterData(List<String> userRole, String userId,
      Map<String, dynamic> _selectedData) async {
    _isLoading = true;
    _filteredData.clear();
    try {
      // Fetch data from the first collection
      QuerySnapshot raisedTicketsSnapshot =
          await _firestore.collection('raisedTickets').get();
      List<DocumentSnapshot> raisedTickets = raisedTicketsSnapshot.docs;

      // Initialize a list to store all ticket documents
      List<Map<String, dynamic>> allTicketData = [];
      for (DocumentSnapshot raisedTicket in raisedTickets) {
        // Fetch tickets for each raised ticket
        QuerySnapshot ticketsSnapshot;
        if (userRole.isEmpty) {
          ticketsSnapshot = await _firestore
              .collection('raisedTickets')
              .doc(raisedTicket.id)
              .collection('tickets')
              .where('user', isEqualTo: userId)
              .get();
        } else {
          ticketsSnapshot = await _firestore
              .collection('raisedTickets')
              .doc(raisedTicket.id)
              .collection('tickets')
              .where('serviceProviderId', isEqualTo: userId)
              .get();
        }
        print('RaisedTicketId ${raisedTicket.id}');

        for (DocumentSnapshot ticket in ticketsSnapshot.docs) {
          print('TicketId ${raisedTicket.id}');
          // Fetch each ticket document
          DocumentSnapshot ticketData = await _firestore
              .collection('raisedTickets')
              .doc(raisedTicket.id)
              .collection('tickets')
              .doc(ticket.id)
              .get();

          if (ticketData.exists) {
            Map<String, dynamic>? ticketDataMap =
                ticketData.data() as Map<String, dynamic>?;

            if (ticketDataMap != null) {
              allTicketData.add(ticketDataMap);
            }
          }
        }
      }

      // Apply filter on the collected ticket data

      List<Map<String, dynamic>> filteredData = allTicketData.where((data) {
        bool matches = true;

        if (_selectedData['selectedStatus'] != null &&
            data['status'] != _selectedData['selectedStatus']) {
          matches = false;
        }

        if (_selectedData['selectedStartDate'] != '' &&
            _selectedData['selectedStartDate'] != null) {
          DateFormat dateFormat = DateFormat("dd-MM-yyyy");

          // Parse the date string into a DateTime object
          DateTime startDate =
              dateFormat.parse(_selectedData['selectedStartDate']);
          DateTime ticketDate = dateFormat.parse(data['date']);

          if (ticketDate.isBefore(startDate)) {
            matches = false;
          }
        }

        if (_selectedData['selectedEndDate'] != '' &&
            _selectedData['selectedEndDate'] != null) {
          DateFormat dateFormat = DateFormat("dd-MM-yyyy");
          DateTime endDate = dateFormat.parse(_selectedData['selectedEndDate']);
          DateTime ticketDate = dateFormat.parse(data['date']);
          if (ticketDate.isAfter(endDate)) {
            matches = false;
          }
        }

        if (_selectedData['selectedTicket'] != null &&
            data['tickets'] != _selectedData['selectedTicket']) {
          matches = false;
        }

        if (_selectedData['selectedWork'] != null &&
            data['work'] != _selectedData['selectedWork']) {
          matches = false;
        }

        if (_selectedData['selectedBuilding'] != null &&
            data['building'] != _selectedData['selectedBuilding']) {
          matches = false;
        }
        if (_selectedData['selectedFloor'] != null &&
            data['floor'] != _selectedData['selectedFloor']) {
          matches = false;
        }

        if (_selectedData['selectedRoom'] != null &&
            data['room'] != _selectedData['selectedRoom']) {
          matches = false;
        }

        if (_selectedData['selectedAsset'] != null &&
            data['asset'] != _selectedData['selectedAsset']) {
          matches = false;
        }
        if (_selectedData['selectedUser'] != null &&
            data['name'] != _selectedData['selectedUser']) {
          matches = false;
        }

        if (_selectedData['selectedServiceProvider'] != null &&
            data['serviceProvider'] !=
                _selectedData['selectedServiceProvider']) {
          matches = false;
        }

        return matches;
      }).toList();
      print('dfdf$filteredData');

      _filteredData = filteredData.reversed.toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Future<void> fetchAndFilterServiceProviderData(
  //   List<String> userRole,
  //     String userId, Map<String, dynamic> _selectedData) async {
  //   _isLoading = true;
  //   _filteredData.clear();
  //   try {
  //     // Fetch data from the first collection
  //     QuerySnapshot raisedTicketsSnapshot =
  //         await _firestore.collection('raisedTickets').get();
  //     List<DocumentSnapshot> raisedTickets = raisedTicketsSnapshot.docs;

  //     // Initialize a list to store all ticket documents
  //     List<Map<String, dynamic>> allTicketData = [];
  //     for (DocumentSnapshot raisedTicket in raisedTickets) {
  //       // Fetch tickets for each raised ticket

  //       QuerySnapshot ticketsSnapshot = await _firestore
  //           .collection('raisedTickets')
  //           .doc(raisedTicket.id)
  //           .collection('tickets')
  //           .where('serviceProviderId', isEqualTo: userId)
  //           .get();

  //       for (DocumentSnapshot ticket in ticketsSnapshot.docs) {
  //         // Fetch each ticket document
  //         DocumentSnapshot ticketData = await _firestore
  //             .collection('raisedTickets')
  //             .doc(raisedTicket.id)
  //             .collection('tickets')
  //             .doc(ticket.id)
  //             .get();

  //         if (ticketData.exists) {
  //           Map<String, dynamic>? ticketDataMap =
  //               ticketData.data() as Map<String, dynamic>?;

  //           if (ticketDataMap != null) {
  //             allTicketData.add(ticketDataMap);
  //           }
  //         }
  //       }
  //     }

  //     // Apply filter on the collected ticket data

  //     List<Map<String, dynamic>> filteredData = allTicketData.where((data) {
  //       bool matches = true;

  //       if (_selectedData['selectedStatus'] != null &&
  //           data['status'] != _selectedData['selectedStatus']) {
  //         matches = false;
  //       }

  //       if (_selectedData['selectedStartDate'] != '' &&
  //           _selectedData['selectedStartDate'] != null) {
  //         DateFormat dateFormat = DateFormat("dd-MM-yyyy");

  //         // Parse the date string into a DateTime object
  //         DateTime startDate =
  //             dateFormat.parse(_selectedData['selectedStartDate']);
  //         DateTime ticketDate = dateFormat.parse(data['date']);

  //         if (ticketDate.isBefore(startDate)) {
  //           matches = false;
  //         }
  //       }

  //       if (_selectedData['selectedEndDate'] != '' &&
  //           _selectedData['selectedEndDate'] != null) {
  //         DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  //         DateTime endDate = dateFormat.parse(_selectedData['selectedEndDate']);
  //         DateTime ticketDate = dateFormat.parse(data['date']);
  //         if (ticketDate.isAfter(endDate)) {
  //           matches = false;
  //         }
  //       }

  //       if (_selectedData['selectedTicket'] != null &&
  //           data['tickets'] != _selectedData['selectedTicket']) {
  //         matches = false;
  //       }

  //       if (_selectedData['selectedWork'] != null &&
  //           data['work'] != _selectedData['selectedWork']) {
  //         matches = false;
  //       }

  //       if (_selectedData['selectedBuilding'] != null &&
  //           data['building'] != _selectedData['selectedBuilding']) {
  //         matches = false;
  //       }
  //       if (_selectedData['selectedFloor'] != null &&
  //           data['floor'] != _selectedData['selectedFloor']) {
  //         matches = false;
  //       }

  //       if (_selectedData['selectedRoom'] != null &&
  //           data['room'] != _selectedData['selectedRoom']) {
  //         matches = false;
  //       }

  //       if (_selectedData['selectedAsset'] != null &&
  //           data['asset'] != _selectedData['selectedAsset']) {
  //         matches = false;
  //       }

  //       if (_selectedData['selectedServiceProvider'] != null &&
  //           data['serviceProvider'] !=
  //               _selectedData['selectedServiceProvider']) {
  //         matches = false;
  //       }

  //       return matches;
  //     }).toList();
  //     print('dfdf$filteredData');

  //     _filteredData = filteredData;
  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }
  // }

  fetchAllData(String userId) async {
    _isopenLoading = true;
    _filteredData.clear();
    try {
      // Fetch data from the first collection
      QuerySnapshot raisedTicketsSnapshot =
          await _firestore.collection('UserNotification').get();
      List<DocumentSnapshot> raisedTickets = raisedTicketsSnapshot.docs;

      // Initialize a list to store all ticket documents
      List<Map<String, dynamic>> allRaisedTicketData = [];

      for (DocumentSnapshot raisedTicket in raisedTickets) {
        // Fetch tickets for each raised ticket
        QuerySnapshot ticketsSnapshot = await _firestore
            .collection('UserNotification')
            .doc(raisedTicket.id)
            .collection('tickets')
            .where('user', isEqualTo: userId)
            .get();

        for (DocumentSnapshot ticket in ticketsSnapshot.docs) {
          // Fetch each ticket document
          DocumentSnapshot ticketData = await _firestore
              .collection('UserNotification')
              .doc(raisedTicket.id)
              .collection('tickets')
              .doc(ticket.id)
              .get();

          if (ticketData.exists) {
            Map<String, dynamic>? ticketDataMap =
                ticketData.data() as Map<String, dynamic>?;

            if (ticketDataMap != null) {
              allRaisedTicketData.add(ticketDataMap);
            }
          }
        }
      }

      // Apply filter on the collected ticket data

      try {
        List<Map<String, dynamic>> openData = allRaisedTicketData.where((data) {
          _isopenLoading = true;
          bool matches = true;

          if (data['status'] != 'Open') {
            matches = false;
          }

          return matches;
        }).toList();

        List<Map<String, dynamic>> closeData =
            allRaisedTicketData.where((data) {
          // _isopenLoading = true;
          bool matches = true;

          if (data['status'] != 'Close') {
            matches = false;
          }

          return matches;
        }).toList();
        _openData = openData;
        _closeData = closeData;
        _closeDataLength = allRaisedTicketData.length - openData.length;
        _isopenLoading = false;
        notifyListeners();
      } catch (e) {
        print('Error fetching data: $e');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  fetchFcmID(String workperson) async {
    try {
      // Fetch data from the first collection
      QuerySnapshot raisedTicketsSnapshot = await _firestore
          .collection('members')
          .where('role', arrayContains: workperson)
          .get();

      if (raisedTicketsSnapshot.docs.isNotEmpty) {
        String userId = raisedTicketsSnapshot.docs[0]['userId'];
        String name = raisedTicketsSnapshot.docs[0]['fullName'];

        DocumentSnapshot tokenData =
            await _firestore.collection('FcmToken').doc(userId).get();

        String? tokenId;
        if (tokenData.exists) {
          // Retrieve 'token' field from the document
          Map<String, dynamic>? data =
              tokenData.data() as Map<String, dynamic>?;

          if (data != null) {
            tokenId = data['fcmToken'];
          }
          _tokenData = tokenId!;
        }
        _serviceProviderName = name;
        _serviceProviderId = userId;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  fetchNotificationData(String userId) async {
    _notifications.clear();
    try {
      // Fetch data from the first collection
      DocumentSnapshot raisedTicketsSnapshot =
          await _firestore.collection('notifications').doc(userId).get();
      Map<String, dynamic>? data =
          raisedTicketsSnapshot.data() as Map<String, dynamic>;

      _notifications = data['notifications'];
      notifications = _notifications;

      // Initialize a list to store all ticket documents
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  fetchPendingTicketData(String userId) async {
    try {
      QuerySnapshot raisedTicketsSnapshot =
          await _firestore.collection('raisedTickets').get();
      List<DocumentSnapshot> raisedTickets = raisedTicketsSnapshot.docs;

      // Initialize a list to store all ticket documents
      List<Map<String, dynamic>> allRaisedTicketData = [];

      for (DocumentSnapshot raisedTicket in raisedTickets) {
        // Fetch tickets for each raised ticket
        QuerySnapshot ticketsSnapshot = await _firestore
            .collection('raisedTickets')
            .doc(raisedTicket.id)
            .collection('tickets')
            .get();

        for (DocumentSnapshot ticket in ticketsSnapshot.docs) {
          // Fetch each ticket document
          DocumentSnapshot ticketData = await _firestore
              .collection('raisedTickets')
              .doc(raisedTicket.id)
              .collection('tickets')
              .doc(ticket.id)
              .get();

          if (ticketData.exists) {
            Map<String, dynamic>? ticketDataMap =
                ticketData.data() as Map<String, dynamic>?;

            if (ticketDataMap != null) {
              allRaisedTicketData.add(ticketDataMap);
            }
          }
        }
      }
      try {
        List<Map<String, dynamic>> data = allRaisedTicketData.where((data) {
          // _isopenLoading = true;
          bool matches = true;
          print(data['serviceProviderId']);

          if (data['serviceProviderId'] != userId) {
            matches = false;
          }

          if (data['status'] != 'Open') {
            matches = false;
          }

          return matches;
        }).toList();
        print(data.length);
        _servicependingData = data.reversed.toList();
        // _servicependingData = servicependingData.reversed.toList();
        _isserviceLoading = false;
        notifyListeners();
      } catch (e) {
        print('Error fetching data: $e');
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateUserSeen(String userId) async {
    try {
      QuerySnapshot raisedTicketsSnapshot =
          await _firestore.collection('raisedTickets').get();
      List<DocumentSnapshot> raisedTickets = raisedTicketsSnapshot.docs;

      // Initialize a list to store all ticket documents
      List<Map<String, dynamic>> allRaisedTicketData = [];

      for (DocumentSnapshot raisedTicket in raisedTickets) {
        // Fetch tickets for each raised ticket
        QuerySnapshot ticketsSnapshot = await _firestore
            .collection('raisedTickets')
            .doc(raisedTicket.id)
            .collection('tickets')
            .where('user', isEqualTo: userId)
            .get();

        for (DocumentSnapshot ticket in ticketsSnapshot.docs) {
          // Fetch each ticket document
          DocumentSnapshot ticketData = await _firestore
              .collection('raisedTickets')
              .doc(raisedTicket.id)
              .collection('tickets')
              .doc(ticket.id)
              .get();

          Map<String, dynamic>? data =
              ticketData.data() as Map<String, dynamic>?;

          // Check if the field exists

          if (data != null && data.containsKey('isUserSeen')) {
            await _firestore
                .collection('raisedTickets')
                .doc(raisedTicket.id)
                .collection('tickets')
                .doc(ticket.id)
                .update({
              'isUserSeen': false,
            });
          }
        }
      }
    } catch (e) {
      print('Error updating user seen: $e');
    }
  }

  Future getNotificationLength(String userId) async {
    _isUserSeen.clear();

    try {
      QuerySnapshot raisedTicketsSnapshot =
          await _firestore.collection('raisedTickets').get();
      List<DocumentSnapshot> raisedTickets = raisedTicketsSnapshot.docs;

      // Initialize a list to store all ticket documents
      List<Map<String, dynamic>> allRaisedTicketData = [];

      for (DocumentSnapshot raisedTicket in raisedTickets) {
        // Fetch tickets for each raised ticket
        QuerySnapshot ticketsSnapshot = await _firestore
            .collection('raisedTickets')
            .doc(raisedTicket.id)
            .collection('tickets')
            .where('user', isEqualTo: userId)
            .get();

        for (DocumentSnapshot ticket in ticketsSnapshot.docs) {
          // Fetch each ticket document
          DocumentSnapshot ticketData = await _firestore
              .collection('raisedTickets')
              .doc(raisedTicket.id)
              .collection('tickets')
              .doc(ticket.id)
              .get();

          Map<String, dynamic>? data =
              ticketData.data() as Map<String, dynamic>?;

          // Check if the field exists

          if (data!['isUserSeen'] == true) {
            _isUserSeen.add(data);
            notifyListeners();
          }
        }
      }
      // Notify listeners after the loop is done
      notifyListeners();
    } catch (e) {
      print('Error updating user seen: $e');
    }
  }

  Future getServiceNotificatioLength(String userId) async {
    _isServiceProviderSeen.clear();
    DocumentSnapshot raisedTicketsSnapshot =
        await _firestore.collection('notifications').doc(userId).get();

    Map<String, dynamic>? data =
        raisedTicketsSnapshot.data() as Map<String, dynamic>?;
    List<dynamic>? notifications = data?['notifications'] as List<dynamic>?;

    if (notifications != null) {
      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i]['isServiceProviderSeen'] == true) {
          _isServiceProviderSeen.add(notifications[i]);
          notifyListeners();
        } else {
          _isServiceProviderSeen.clear();
          notifyListeners();
        }
      }
    }
  }

  Future updateServiceUserSeen(String userId) async {
    // Fetch tickets for each raised ticket

    List<dynamic> notificationData = [];

    DocumentSnapshot raisedTicketsSnapshot =
        await _firestore.collection('notifications').doc(userId).get();

    Map<String, dynamic>? data =
        raisedTicketsSnapshot.data() as Map<String, dynamic>?;
    List<dynamic>? notifications = data?['notifications'] as List<dynamic>?;

    if (notifications != null) {
      // Cast the dynamic list to a list of maps
      List<Map<String, dynamic>> notificationList =
          notifications.cast<Map<String, dynamic>>();

      // Update the specific notification
      List<Map<String, dynamic>> updatedNotifications =
          notificationList.map((notification) {
        if (ticketId.contains(notification['TicketId'])) {
          // Update the specific notification
          return {...notification, 'isServiceProviderSeen': false};
        }
        return notification;
      }).toList();

      // Save the updated notifications list back to Firestore
      await _firestore
          .collection('notifications')
          .doc(userId)
          .update({'notifications': updatedNotifications});

      // for (int i = 0; i < notifications.length; i++) {
      //   if (notifications[i]['isServiceProviderSeen'] == true) {
      //     _isServiceProviderSeen.add(notifications[i]);
      //     notifyListeners();
      //   }
      // }

      print('Notification status updated successfully.');
    } else {
      print('No notifications field found.');
    }

    notificationData = data!['notifications'];
  }

  void addTicketId(String item) {
    _ticketId.add(item);
    notifyListeners();
  }

  void clearTickets() {
    _ticketId.clear();
    notifyListeners();
  }
}
