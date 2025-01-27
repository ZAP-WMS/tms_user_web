// Example ModuleController to manage state
import 'package:get/get.dart';

import '../view/home_page.dart';

class ModuleController extends GetxController {
  RxString selectedModule = "Raised Ticket".obs; // Holds the selected module
  RxBool checkRole = false.obs;

  // Method to select a module
  void selectModule(String moduleName) {
    selectedModule.value = moduleName;
  }

  void checkRoles(String userId) async {
    checkRole.value = await checkUserRole(userId);
  }
}
