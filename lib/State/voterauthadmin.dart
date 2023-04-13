import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:election/pages/Admin/DashBoard.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

import '../services/functions.dart';
import '../utils/Constants.dart';

class AuthVoterController extends GetxController{


  bool isloading = false;

  @override
  void onInit() {
    isloading = false;
    super.onInit();
  }



  Future<void> registerAuth(String adhar,String electionName) async {
    try {
      loadingbar();
      await FirebaseFirestore.instance
          .collection('Election')
          .doc(electionName)
          .collection('voterAuth')
          .doc(adhar)
          .update({'isAuth': true});
      if (kDebugMode) {
        print('updated data aaaaaaaaaaaaaaa');
      }
      loadingbaroff();
      //showSnackBar(succesAdharSnack);
    } catch (e) {
      if (kDebugMode) {
        print('failed to register on firebase $e');
      }
      loadingbaroff();
      //showSnackBar(errorAdharSnack);
    }
    loadingbaroff();
  }

  //variables declared
  late int _adharage = 19;
  late bool _is_adhar_verified = false;
  late int _adharnum = 12345678;

  Future<void> getAdharVerified(String adharnum) async {
    try {
      final DocumentSnapshot adhars = await FirebaseFirestore.instance
          .collection('Adhars')
          .doc(adharnum)
          .get();
      if (adhars.data() != null) {
        _adharage = adhars.get('age');
        _is_adhar_verified = adhars.get('verified');
        _adharnum = adhars.get('adharnum');
        //showSnackBar(succesAdharSnack);
      }
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('get adhar verified failed ::::: $e');
        }
      }
      //showSnackBar(errorAdharSnack);
    }
  }

  //big authorize function

  bigAuthorize(AuthVoterController authVoterController,String electionName,String voterAdress, String adhar,Web3Client ethClient,String electionAddress) async {
    bool isAuthorized = false;
    try{
      loadingbar();
      await authorizeVoter(voterAdress, ethClient, owner_private_key, electionAddress);
      isAuthorized = true;
      loadingbaroff();
    }catch(e){
      loadingbaroff();
      Get.snackbar("error", "$e");
      isAuthorized = false;
    }
    if(isAuthorized == true){
      registerAuth(adhar,electionName);
    }else{
      loadingbaroff();
      Get.snackbar("error", "cannot register the voter ");
      isAuthorized = false;
    }
    loadingbaroff();
  }

  void loadingbar() {
    isloading = true;
    update();
  }

  void loadingbaroff() {
    isloading = false;
    update();
  }

}