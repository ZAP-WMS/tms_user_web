import 'package:get/get.dart';
import 'package:flutter/material.dart';

class WorkController extends GetxController {
  // Observable variables (state management)
  var workTypes = <String>[].obs; // Observable list of work types
  var isLoading = true.obs; // Observable for loading state
  var errorMessage = ''.obs; // Observable for error message

  // TextEditingController to manage selected work type in a TextField
  TextEditingController workTypeController = TextEditingController();

  // // AuthService to fetch data
  // final AuthService authService = AuthService();

  // Method to fetch work types
  Future<void> fetchWorkTypes() async {
    // try {
    //   isLoading(true); // Set loading state to true
    //   final workModel = await authService.getWork();

    //   workTypes.value = workModel!.data.map((item) => item.name).toList();
    //   // if (workTypes.isNotEmpty) {
    //   //   workTypeController.text = workTypes.first;
    //   // }
    //   isLoading(false); // Set loading state to false
    // } catch (error) {
    //   errorMessage.value = error.toString();
    //   isLoading(false); // Set loading state to false
    // }
  }

  // Method to reset selection
  void resetSelections() {
    workTypeController.text = 'Select Work'; // Reset the text to default value
  }
}
