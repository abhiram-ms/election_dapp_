import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../Models/Firebase/firebase_api.dart';
import '../Models/Firebase/firebase_file.dart';
import '../Models/candidates_model.dart';
import '../pages/Voter/VoterHome.dart';
import '../services/functions.dart';
import '../utils/Constants.dart';

class VoteController extends GetxController{

  //declaring needed variables
  final String? electionName;
  final String? electionAddress;
  final Map<String,dynamic> electionData;
  final Map<String,dynamic>?  votermap;

  VoteController(this.electionName,this.electionAddress,this.electionData,this.votermap);

  //creating clients
  late Client? httpClient;//http client
  late Web3Client? ethclient;// eth client

  @override
  void onInit() {
    httpClient = Client();
    ethclient = Web3Client(infura_url, httpClient!);
    getUserDetail(electionName!, votermap);
    super.onInit();
    futureFiles = FirebaseApi.listAll('electionimages/$electionName/partyimages/candidates');
    candidateset.clear();
  }


  // checking weather voter is already voted or not

  //checking if the voter is already voted
  late bool isAuth = false;
  late bool isVoted = false;

  late Future<List<FirebaseFile>> futureFiles;
  late int candidatesNum = 0;

  final Set<Candidates> candidateset = {}; // your data goes here

  Future<void>getUserDetail(String electionName, Map<String,dynamic>? voterMap ) async {
    var voterDetails = voterMap;
    try {
      fetching();
      final DocumentSnapshot voters = await FirebaseFirestore.instance
          .collection('Election')
          .doc(electionName).collection('voterAuth').doc(voterDetails!['adharnum'])
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

  // function to make voting
  voteBigFunction(int i,String privateKey)async{
    bool isSuccess = false;
    try{
      fetching();
      await vote(i,ethclient!,privateKey,electionAddress!);
      isSuccess = true;
    }catch(e){
      fetchingOff();
      isSuccess = false;
      Get.snackbar("error", "$e");
    }
    if(isSuccess == true){
      await registerAuth();
    }
    fetchingOff();
    isSuccess = false;
    gotoDashboard();
  }
  Future<void> registerAuth() async {
    var voterDetails = votermap;
    try {
      fetching();
      await FirebaseFirestore.instance.collection('Election').doc(electionName).collection('voterAuth').doc(voterDetails!['adharnum']).update({'isVoted':true});
      if (kDebugMode) {
        print('updated data aaaaaaaaaaaaaaa');
      }
    } catch (e) {
      fetchingOff();
      Get.snackbar("failed to vote", "$e");
      if (kDebugMode) {
        print('failed to register on firebase $e');
      }
    }
    fetchingOff();
  }
  void gotoDashboard(){
    Get.offAll(()=>VoterHome(ethClient: ethclient, electionName: electionName,
      electionAddress: electionAddress, electionData:electionData,));
  }

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