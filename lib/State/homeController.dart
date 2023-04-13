
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:election/pages/Voter/VoterHome.dart';
import 'package:election/services/Pickelection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../services/Auth.dart';
import '../services/IntoLogin.dart';
import '../services/functions.dart';
import '../utils/Constants.dart';

class HomeController extends GetxController{

  @override
  void onInit() {
    usernow = auth.currentUser!;
    httpClient = Client();
    ethclient = Web3Client(infura_url, httpClient!);
    try {
      getData();
    } catch (e) {
      isTrue = false;
    }
    super.onInit();
  }
//-----------------------------------------------------------------------------> ADMIN HOME(START ELECTION)
  //creating clients
  late Client? httpClient;
  late Web3Client? ethclient;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentuser => _firebaseAuth.currentUser;

  //INITIATE FIREBASE AUTH
  final auth = FirebaseAuth.instance;

  //CURRENT USER
  late User usernow;

  //variables used
  late String? userEmail = currentuser?.email; //EMAIL OF CURRENT USER
  late String adminName = 'admin';
  late bool isTrue = false;
  late String phone = 'not fetched';
  late bool isAdharVerified = false;
  late bool startElection = false;

  //GET USER DATA FROM FIREBASE AUTHENTICATION
  Future<void> getData() async {//CHECKING ADMINS DATA IF THE ELECTION IS STARTED OR NOT
    try {
      final DocumentSnapshot admins = await FirebaseFirestore.instance
          .collection('Admins')
          .doc(userEmail!)
          .get();
      if (admins.data() != null) {
        adminName = admins.get('Name');
        isTrue = admins.get('Admin');
        phone = admins.get('phone');
        isAdharVerified = admins.get('adharverified');
        startElection = admins.get('electionStarted');
        // refresh();
      }
    } catch (e) {
      if (kDebugMode) {
        print('get data failed : :: :: : $e');
      }
    }
  }

  //date constants
  DateTime date = DateTime(2022, 12, 30);
  late String unix;
  late String unixlast;

  //get dates
  Future<void> getDate(BuildContext context,TextEditingController dateinput) async {
    DateTime? newdate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (newdate == null) return;
    date = newdate;
    unix = DateTime(newdate.year, newdate.month, newdate.day)
        .millisecondsSinceEpoch
        .toString()
        .substring(0, 10);
    if (kDebugMode) {
      print('the unix time stamp is $unix');
    }
    dateinput.text = '${newdate.year}/${newdate.month}/${newdate.day}';
    update();
  }
  Future<void> getEndDate(BuildContext context,TextEditingController dateinputend) async {
    DateTime? newdatelast = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (newdatelast == null) return;
    date = newdatelast;
    unixlast = DateTime(newdatelast.year,
        newdatelast.month, newdatelast.day)
        .millisecondsSinceEpoch
        .toString()
        .substring(0, 10);
    if (kDebugMode) {
      print('the unix time stamp is $unixlast');
    }
    dateinputend.text = '${newdatelast.year}/${newdatelast.month}/${newdatelast.day}';
    update();
  }

  //election functions
   late int adharage = 10;
   late int adharnum = 1234567890;
  //Start Election Complete
  void startElectionComplete(String adharnum,String electionName,String state,String district,String privateKey) async {
    // the code to start election from adhar verification,register election and create election at blockchain

    //adhar verification
    if (kDebugMode) {print('verifying adhar');}
    await getAdharVerified(adharnum); //ADHAR VERIFICATION FUNCTION
    if (kDebugMode) {print('adhar verified');}

    // CHECKING AGE FROM AADHAAR
    if (adharage > 18 ) {
      if (kDebugMode) {print('adhar verification complete');} // CHECKING WEATHER ELECTION DATES ARE GIVEN
      if (unixlast.isNotEmpty && unix.isNotEmpty) {
        if (kDebugMode) {print('unix not nulls');}

        try {
          //Registering election
          if (kDebugMode) {print('registering');}
          await registerElec(unix, unixlast,electionName,state,district); // REGISTERING THE ELECTION IN FIREBASE
          if (kDebugMode) {print('creating blockchain');}

          //AFTER REGISTRATION CREATING ELECTION ON BLOCKCHAIN
          loadingBar();
          await createElection(electionName, ethclient!, privateKey, contractAdressConst);
          loadingBarOff();
          gotoPickElec();

        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
          Get.snackbar('error occured', '$e');
        }
      }else{Get.snackbar('error occured', 'error fill all details');}
    }else{Get.snackbar('error occurred', 'error fill all details');}
    loadingBarOff();
  }
  //Register election
  Future<void> registerElec(String timestampStart, String timestampEnd,String electionName,String state,String district) async {
    if (kDebugMode) {
      print('reg elec');
    }
    loadingBar();
    final CollectionReference election = FirebaseFirestore.instance.collection('Election');

    try {
      await election.doc(electionName).set({
        "startdate": timestampStart,
        "enddate": timestampEnd,
        "name": electionName,
        "state": state,
        "district":district,
        "endedElection":false,
      });
      if (kDebugMode) {
        print('user added successfullyyyyyyy');
      }
    } catch (err) {
      Get.snackbar('error occured', '$err');
    }
    loadingBarOff();
  }

  //Go to pick election
  void gotoPickElec() {
    Get.offAll(()=> const Pickelec(admin: true));
  }

  //loading bar variable
  bool isLoading = false;
  void loadingBar(){
    isLoading = true;
    update();
  }
  void loadingBarOff(){
    isLoading = false;
    update();
  }

  //---------------------------------->ADHAR VERIFICATION
  //AADHAAR VERIFICATION FROM FIREBASE
  Future<void> getAdharVerified(String adharnumber) async {
    adharBar();
    try {
      final DocumentSnapshot adhars = await FirebaseFirestore.instance
          .collection('Adhars')
          .doc(adharnumber)
          .get();
      if (adhars.data() != null) {
        //IF THE DATA IS NOT NULL
        adharage = adhars.get('age');
        adharnum = adhars.get('adharnum');
      }
    } catch (e) {
      if (kDebugMode) {
        print('get adhar verified failed ::::: $e');
      }
      Get.snackbar('adhar verification failed', '$e');
    }
    adharBarOff();
  }
  //adhar verifying bar
  bool isaAdharVerifying = false;
  void adharBar(){
    isaAdharVerifying = true;
    update();
  }
  void adharBarOff(){
    isaAdharVerifying = false;
    update();
  }
  //------------------------------------------------------------------->>>>>>>> Sign out function
  Future<void> signOut() async {
    await Auth().signOut();
    Get.offAll(()=> const IntroLogin());
  }
  ////------------------------------------------------------------------>>>>>>> PICK ELECTION CONTROLLER
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
  //------------------------------------------------------------>>>>>>>>>>>>>>  voter pick election

  Future<void> getElectionData(String electionName,String electionAddress) async {
    try{
      fetching();
      final DocumentSnapshot election = await FirebaseFirestore.instance
          .collection('Election')
          .doc(electionName)
          .get();
      if (election.data() != null) {
        //IF THE DATA IS NOT NULL
        Map<String,dynamic> electionData = {
          "endedElection":election.get("endedElection"),"endDate":election.get("enddate"),
          "startDate":election.get("startdate"),"electionName":election.get("name"),
          "district":election.get("district"),"state":election.get("state"),
        };
        if (kDebugMode) {
          print("we got ::: $electionData ");
        }
        Get.offAll(()=>VoterHome(ethClient: ethclient, electionName: electionName,
            electionAddress: electionAddress, electionData: electionData));
      }else{
        fetchingOff();
        Get.snackbar("error","election data is not included in database wait till then");
      }
    }catch(e){
      if (kDebugMode) {
        print("this is errorr in fetching election data ::::: $e");
      }
      fetchingOff();
      Get.snackbar("error","election data is not included in database wait till then");
    }
    fetchingOff();
  }

}