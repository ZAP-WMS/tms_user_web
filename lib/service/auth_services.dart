import 'package:flutter/material.dart';
import 'package:tms_useweb_app/view/LoginPage/login_page.dart';

class AuthService {
  // Logout function
  Future<void> logout(BuildContext context) async {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }
  // Function to check if the user is already logged in
  // static Future<bool> isLoggedIn() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // Check for the stored token or user data
  //   final token = prefs.getString('auth_token');

  //   bool c = token != null ? true : false;
  //   return c; // If token is found, user is logged in
  // }

  // // Function to handle login
  // Future<User?> login(String username, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(ApiConstants.loginUrl), // Use the constant for login URL
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'userId': username, 'password': password}),
  //     );

  //     if (response.statusCode == 200) {
  //       // If the response is successful, parse the response
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       final user = User.fromJson(responseData['user']);
  //       Get.offNamed('/home-page');
  //       // Save the token to SharedPreferences if login is successful
  //       final prefs = await SharedPreferences.getInstance();

  //       await prefs.setString('auth_token', user.users.first.id);

  //       return user;
  //     } else {
  //       Get.showSnackbar(const GetSnackBar(
  //         duration: Duration(seconds: 5),
  //         title: 'Error',
  //         message: 'Failed to login. Please check your credentials.',
  //         backgroundColor: AppColors.redColor,
  //       ));
  //       throw Exception('Failed to login. Please check your credentials.');
  //     }
  //   } catch (e) {
  //     throw Exception('An error occurred while logging in.');
  //   }
  // }

  // Future<WorkModel?> getWork() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(ApiConstants.workDataUrl), // Use the constant for login URL
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       // If the response is successful, parse the response
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       WorkModel workModel = WorkModel.fromJson(responseData);

  //       return workModel;
  //     } else {
  //       Get.showSnackbar(const GetSnackBar(
  //         duration: Duration(seconds: 5),
  //         title: 'Error',
  //         message: 'Unable to fetch Data.',
  //         backgroundColor: AppColors.redColor,
  //       ));
  //       throw Exception('Unable to fetch Data.');
  //     }
  //   } catch (e) {
  //     throw Exception('An error occurred while logging in.');
  //   }
  // }

  // Future<UserElement?> getUserDetails() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // Check if there's an existing token
  //   String? authToken = prefs.getString('auth_token');

  //   if (authToken != null) {
  //     // If there's an existing token, fetch user details from the API or locally
  //     final response = await fetchUserDetails(
  //         authToken); // Replace with your API call to fetch user info

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       final user = UserElement.fromJson(responseData['users'][0]);
  //       return user;
  //     } else {
  //       Get.showSnackbar(const GetSnackBar(
  //         duration: Duration(seconds: 5),
  //         title: 'Server Error',
  //         message: 'Failed to login. Please contact to Abdul.',
  //         backgroundColor: AppColors.redColor,
  //       ));
  //       // Handle failure (e.g., token expired, request failed)
  //       print('Failed to fetch user details');
  //       return null;
  //     }
  //   } else {
  //     // Token does not exist, so user is not logged in
  //     print('No user found, user is not logged in');
  //     return null;
  //   }

  // }

  // Future<http.Response> fetchUserDetails(String authToken) async {
  //   final url = Uri.parse(ApiConstants.allUserUrl); // Replace with your API URL

  //   // Send a GET request with the auth token in the Authorization header
  //   final response = await http.get(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   return response;
  // }
}
