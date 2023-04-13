import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:election/pages/Admin/DashBoard.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../services/functions.dart';
import '../utils/Constants.dart';

class EndController extends GetxController{

  //declaring needed variables
  final String? electionName;
  final String? electionAddress;

  EndController(this.electionName,this.electionAddress,);

  //creating clients
  late Client? httpClient;//http client
  late Web3Client? ethclient;// eth client


  @override
  void onInit() {
    httpClient = Client();
    ethclient = Web3Client(infura_url, httpClient!);
    super.onInit();
  }

  Future<void> toCloseElection(String electionName,String aadhaar,String metamaskKey,String electionAddress) async {
    bool isSuccess = false;
    try{
      fetching();
      await closeElection(ethclient!, metamaskKey, electionAddress);
      isSuccess = true;
    }catch(e){
      fetchingOff();
      isSuccess = false;
      Get.snackbar("error", "$e");
    }
    if(isSuccess == true){
      await registerCloseElection();
    }
    fetchingOff();
    isSuccess = false;
    gotoDashboard();
  }

  Future<void> registerCloseElection() async {
    try {
      fetching();
      await FirebaseFirestore.instance.collection('Election').doc(electionName).update({'endedElection':true,});
      if (kDebugMode) {
        print('updated data aaaaaaaaaaaaaaa');
      }
    } catch (e) {
      fetchingOff();
      Get.snackbar("failed to close election", "$e");
      if (kDebugMode) {
        print('failed to register on firebase $e');
      }
    }
    fetchingOff();
  }

  void gotoDashboard(){
    Get.offAll(()=>DashBoard(ethClient: ethclient!, electionName: electionName!,electionAddress: electionAddress!));
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

  bool isOverlay = false;
  void overlay(){
    isOverlay = true;
    update();
  }
  void overlayOff(){
    isOverlay = false;
    update();
  }

}