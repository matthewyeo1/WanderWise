
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 12 && password.length <= 20 && RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
}

bool isValidUsername(String username) {
  return username.length >= 4 && username.length <= 15;
}

