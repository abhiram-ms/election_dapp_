

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../pages/Voter/VoterHome.dart';
import '../services/Auth.dart';
import '../utils/Constants.dart';

class VoterHomeController extends GetxController{

  //creating clients
  late Client? httpClient;//http client
  late Web3Client? ethclient;// eth client

  late String _electionName;
  late String _electionAddress;
  late Map<String,dynamic> _electionData;

  Future<void> initializer(String electionName,String electionAddress,Map<String,dynamic> electionData) async {
    httpClient = Client();
    ethclient = Web3Client(infura_url, httpClient!);
    _electionName = electionName;
    _electionAddress = electionAddress;
    _electionData = electionData;
    await getUserDetail();
  }

  // voters info
  String? email;
  String? adhar;
  String? name;
  String? phone;
  String? state;
  String? district;
  Map<String,dynamic>? voterData;

  Future<void>getUserDetail() async {
    try {
      fetching();
      final DocumentSnapshot voters = await FirebaseFirestore.instance
          .collection('voters')
          .doc(Auth().currentuser!.email)
          .get();
      if (voters.data() != null) {
        email = voters.get('e-mail');
        name = voters.get('Name');
        phone = voters.get('phone');
        adhar = voters.get('adhar');
        state = voters.get('state');
        voterData = {'name':name,'adharnum':adhar.toString(),'email':email,'phone':phone,'state':state,};
        if (kDebugMode) {
          print('adhar is $adhar');
        }
      }else{
        fetchingOff();
        if (kDebugMode) {
          print('cannot find details');
        }
        Get.snackbar("error", "error you have not registered yourself");
      }
    } catch (e) {
      fetchingOff();
      if (kDebugMode) {
        print('get check user ::::: $e');
        Get.snackbar("error", "error occurred voter details not fetched");
      }
    }
    fetchingOff();
    update();
  }//function to check ends


//------------------------------------------------------------------------->>>>> Vote Register controller
  Future<void> initializerVoteRegister() async {
    isAuth = false;
    isVoted = false;
  }

  Future<void> registerVoterAuthorize(String adharnum,String voterAdress,String voterName,
      String voterAge,String? email,String state,) async {
    try {
      fetching();
      final CollectionReference voterAuth = FirebaseFirestore.instance.collection('Election')
          .doc(_electionName).collection('voterAuth');
      await voterAuth.doc(adharnum).set({
        "adharnum":adharnum,"isVoted":false,"isAuth":false,
        "voterAddress":voterAdress,"voterName":voterName,"voterAge":voterAge,"email":email,
        "state":state,
      });
      Get.offAll(()=>VoterHome(ethClient:ethclient!, electionName:_electionName, electionAddress:_electionAddress,
        electionData:_electionData,));
      Get.snackbar("success","you have registered for voting");
      if (kDebugMode) {
        print('user added successfullyyyyyyy');
      }
    } catch (e) {
      fetchingOff();
      if (kDebugMode) {
        print('Registration failed ::::: $e');
      }
      Get.snackbar("Error","$e");
    }
    fetchingOff();
  }

  
  late bool isAuth = false;
  late bool isVoted = false;

  Future<void>getUserDetailToCheckAuth(String electionName,Map<String,dynamic> voterMap,) async {
    try {
      fetching();
      final DocumentSnapshot voters = await FirebaseFirestore.instance
          .collection('Election')
          .doc(electionName).collection('voterAuth').doc(voterMap["adhar"])
          .get();
      if (voters.data() != null) {
        isAuth = voters.get('isAuth');
        isVoted = voters.get('isVoted');
        if (kDebugMode) {
          print('is auth is :$isAuth && is voted is : $isVoted');
        }
      }else{
        isAuth = false;
        isVoted = false;
        if (kDebugMode) {
          print(isAuth);
        }
        if (kDebugMode) {
          print('cannot find details');
        }
        fetchingOff();
      }
    } catch (e) {
      fetchingOff();
      Get.snackbar("error", "error checking the user");
      isAuth = false;
      isVoted = false;
      if (kDebugMode) {
        print('get check user ::::: $e');
      }
    }
    fetchingOff();
    update();
  }//function to check ends

  //-------------------------------------------------->>>>>>>>>>>>
//fetching bar variable
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