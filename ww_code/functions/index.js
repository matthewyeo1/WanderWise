
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.deleteUserData = functions.auth.user().onDelete((user) => {
  const uid = user.uid;
  const userRef = admin.firestore().collection("Users").doc(uid);

  return userRef.delete();
});
