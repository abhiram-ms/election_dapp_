import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class VoterCardController extends GetxController{
  String electionName;
  Map<String,dynamic>? votermap;

  VoterCardController(this.electionName,this.votermap);

  @override
  void onInit() {
    getUserDetail(electionName, votermap);
    super.onInit();
  }

  //checking if the voter is already voted
  late bool isAuth = false;
  late bool isVoted = false;

  Future<void>getUserDetail(String electionName, Map<String,dynamic>? votermap ) async {
    var voterdetails = votermap;
    try {
      fetching();
      final DocumentSnapshot voters = await FirebaseFirestore.instance
          .collection('Election')
          .doc(electionName).collection('voterAuth').doc(voterdetails!['adharnum'])
          .get();
      if (voters.data() != null) {
        if (kDebugMode) {
          print("isAuth captured.....");
        }
        isAuth = voters.get('isAuth');
        isVoted = voters.get('isVoted');
        if (kDebugMode) {
          print("is auth value is : $isAuth");
        }
      }else{
        isAuth = false;
        isVoted= false;
        if (kDebugMode) {
          print('cannot find details');
        }
        fetchingOff();
      }
    } catch (e) {
      fetchingOff();
      isAuth = false;
      isVoted= false;
      Get.snackbar("error","$e");
      if (kDebugMode) {
        print('get check user ::::: $e');
      }
    }
    fetchingOff();
    update();
  }//function to check ends

  bool isFetching = false;
  void fetching(){
    isFetching = true;
    update();
  }
  void fetchingOff(){
    isFetching = false;
    update();
  }

}