import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RaiseDataProvider extends ChangeNotifier {
  List<String> buildingOptions = [];
  List<String> floorOptions = [];
  List<String> roomOptions = [];
  List<String> assetOptions = [];
  List<String> workOptions = [];

  String? _selectedBuilding;
  String? _selectedFloor;
  String? _selectedRoom;
  String? _selectedWork;
  String? _selectedAsset;

  List<String> get workData => workOptions;
  List<String> get buildingOption => buildingOptions;
  List<String> get floorOption => floorOptions;
  List<String> get roomOption => roomOptions;
  List<String> get assetOption => assetOptions;
  List<String> get workOption => workOptions;

  String? get selectedWork => _selectedWork;
  String? get selectedBuilding => _selectedBuilding;
  String? get selectedFloor => _selectedFloor;
  String? get selectedRoom => _selectedRoom;
  String? get selectedAsset => _selectedAsset;

  // Add methods to set the selected values

  void setSelectedWork(String work) {
    _selectedWork = work;
    notifyListeners();
  }

  void setSelectedBuilding(String building) {
    _selectedBuilding = building;
    notifyListeners();
  }

  void setSelectedFloor(String floor) {
    _selectedFloor = floor;
    notifyListeners();
  }

  void setSelectedRoom(String room) {
    _selectedRoom = room;
    notifyListeners();
  }

  void setSelectedAsset(String asset) {
    _selectedAsset = asset;
    notifyListeners();
  }

  void resetSelections() {
    _selectedBuilding = null;
    _selectedFloor = null;
    _selectedRoom = null;
    _selectedWork = null;
    _selectedAsset = null;
    assetOption.clear();
    notifyListeners();
  }

  void resetSpecificSelection() {
    _selectedRoom = null;
    notifyListeners();
  }

  Future<void> fetchData() async {
    await getBuilding();
    await getFloor();
    await getRoom();
    await getWork();
  }

  Future<void> getBuilding() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('buildingNumbers').get();
    if (querySnapshot.docs.isNotEmpty) {
      buildingOptions = querySnapshot.docs.map((e) => e.id).toList();
      notifyListeners();
    }
  }

  Future<void> getFloor() async {
    if (_selectedBuilding == null) return;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('buildingNumbers')
        .doc(_selectedBuilding)
        .collection('floorNumbers')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      floorOptions = querySnapshot.docs.map((e) => e.id).toList();
      notifyListeners();
    }
  }

  Future<void> getRoom() async {
    if (_selectedBuilding == null || _selectedFloor == null) return;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('buildingNumbers')
        .doc(_selectedBuilding)
        .collection('floorNumbers')
        .doc(_selectedFloor)
        .collection('roomNumbers')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      roomOptions = querySnapshot.docs.map((e) => e.id).toList();
      notifyListeners();
    }
  }

  Future<void> getAsset(String selected, String selectedRoom) async {
    if (selected.isNotEmpty) {
      selectedAsset == null;
      assetOptions.clear();
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     // .collection('buildingNumbers')
      //     // .doc(_selectedBuilding)
      //     // .collection('floorNumbers')
      //     // .doc(_selectedFloor)  k
      //     // .collection('roomNumbers')
      //     // .doc(_selectedRoom)
      //     .collection('assets')
      //     .where('workListByAsset', isEqualTo: selected)
      //     .get();
      QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
          .collection('buildingNumbers')
          .doc(_selectedBuilding)
          .collection('floorNumbers')
          .doc(_selectedFloor)
          .collection('roomNumbers')
          .doc(selectedRoom)
          .collection('assets')
          .where('workListByAsset', isEqualTo: selected)
          .get();
      if (querySnapshot2.docs.isNotEmpty)
      // && (querySnapshot2.docs.isNotEmpty))
      {
        assetOptions = querySnapshot2.docs.map((e) => e.id).toList();
        notifyListeners();
      }
    }
  }

  Future<void> getWork() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('works').get();
    if (querySnapshot.docs.isNotEmpty) {
      workOptions = querySnapshot.docs.map((e) => e.id).toList();
      notifyListeners();
    }
  }
}
