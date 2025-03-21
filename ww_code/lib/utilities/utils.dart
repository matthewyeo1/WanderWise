

bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 12 && password.length <= 20 && RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
}

bool isValidUsername(String username) {
  return username.length >= 4 && username.length <= 15;
}

bool isValidBio(String bio) {
  return bio.length <= 30;
}

bool isValidBudget(int budget) {
  return budget >= 100; 
}

bool isValidDestination(String destination) {
  return !RegExp(r'^[0-9]+$').hasMatch(destination);
}

bool isValidDuration(int duration) {
  return duration >= 1 && duration <= 30;
}

