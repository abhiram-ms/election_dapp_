import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../Models/Firebase/firebase_api.dart';
import '../Models/Firebase/firebase_file.dart';
import '../Models/candidates_model.dart';
import '../services/Auth.dart';
import '../services/IntoLogin.dart';
import '../services/functions.dart';
import '../utils/Constants.dart';

class DashBoardController extends GetxController{

  late Client? httpClient;
  late Web3Client? ethclient;
  @override
  void onInit() {
    httpClient = Client();
    ethclient = Web3Client(infura_url, httpClient!);

    super.onInit();
  }

  //variables for election data
  late String electionName;
  late String electionDistrict;
  late String electionState;
  late String electionEnd;
  late String electionStart;
  late bool endedElection;
  late Map<String,dynamic> electionDataAdmin;

  void initializeDashBoard(String electionName,String electionAddress){
    Map<String,dynamic> electionData = {"electionName" : electionName, "electionAddress" : electionAddress,};
    elecdata.write('elecData',electionData);

    fetchElectionData(electionName);
  }

  Future<void> fetchElectionData(String electionNameGiven)async{
    try {
      loadingBar();
      final DocumentSnapshot election = await FirebaseFirestore.instance
          .collection('Election')
          .doc(electionNameGiven)
          .get();
      if (election.data() != null) {
        electionName = election.get('name'); //assign adhars age to adharage
        electionState = election.get('state'); //store adharnum in this variablee
        electionDistrict = election.get('district');
        electionEnd = election.get('enddate');
        electionStart = election.get('startdate');
        endedElection = election.get('endedElection');

        Map<String,dynamic> electionData = {
          "endedElection":election.get("endedElection"),"endDate":election.get("enddate"),
          "startDate":election.get("startdate"),"electionName":election.get("name"),
          "district":election.get("district"),"state":election.get("state"),
        };
        electionDataAdmin = electionData;
        update();
        loadingBarOff();
      }
    } catch (e) {
      loadingBarOff();
      if (kDebugMode) {
        print('get electionData failed ::::: $e');
      }
      Get.offAll(()=>const IntroLogin());
      Get.snackbar('Error','Fetching electionData failed');
    }
    loadingBarOff();
  }

  //loading screen
  late bool isloading = false;
  loadingBar(){
    isloading = true;
    update();
  }
  loadingBarOff(){
    isloading = false;
    update();
  }


  ////------------------------------------------------------------------->>>>>>>>>>>Add Candidate Controller

  late int numberOfCandidates;
  File? filetodisplay;
  late bool isselected = false;
  UploadTask? uploadTask;

//function to pick files to upload
  Future<void> pickCandidatePhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      filetodisplay = File(file.path.toString());
      //String filename = file.name.toString();
      isselected=true;

      if (kDebugMode) {
        print(file.name);
        print(file.bytes);
        print(file.size);
        print(file.extension);
        print(file.path);
      }
      update();
    } else {
      isselected=false;
      update();
      // User canceled the picker
    }
  }

  // Getting adhar verified for candidate :::
  //variables declared
  late int adharAge;
  late int adharnumCandidate;
  late String name;
  late String address;
  late String mobile;
  late String email;
  late String district;
  late String state;
  late String dob;
  late bool adharVerified;

//get adhar verification function to get adhar details of the candidate
  Future<void> getAdharVerifiedCandidate(String adharnum) async {
    try {
      adharBar();
      final DocumentSnapshot adhars = await FirebaseFirestore.instance
          .collection('Adhars')
          .doc(adharnum)
          .get();
      if (adhars.data() != null) {
        adharAge = adhars.get('age'); //assign adhars age to adharage
        adharnumCandidate = adhars.get('adharnum'); //store adharnum in this variablee
        name = adhars.get('name');
        address = adhars.get('address');
        district = adhars.get('district');
        state = adhars.get('state');
        email = adhars.get('email');
        mobile = adhars.get('mobileNum');
        dob = adhars.get('dob');
        update();
        adharBarOff();
      }
    } catch (e) {
      adharBarOff();
      if (kDebugMode) {
        print('get adhar verified failed ::::: $e');
      }
      Get.snackbar('Error','Verifying adhar has an error');
    }
  }

  //function to add candidate
  Future<void> addCandidateAndUpload(Map<String,dynamic> candidateData,String electionName,String electionAdress,String mtmskKey) async {
    adharBar();
    await uploadImageAndData(candidateData,electionName).then((value) => {
      addCandidate(candidateData["Name"],ethclient!,mtmskKey, electionAdress),
    });
    adharBarOff();
  }

  //function to upload image and documents
  Future<void> uploadImageAndData(Map<String,dynamic> candidateData,String electionName) async{
    //file path and reference to storage
    final String filepath = 'electionimages/$electionName/partyimages/candidates/${candidateData["Name"]}/';
    final storageref = FirebaseStorage.instance.ref().child(filepath);
    //reference to add data to collection
    final DocumentReference candidate = FirebaseFirestore.instance.collection('Election').doc(electionName)
        .collection('candidates').doc(candidateData["adharnum"]);
    try{
      adharBar();
      //uploading picture
      uploadTask = storageref.putFile(filetodisplay!) ;
      //final snapshot = await uploadTask?.whenComplete((){});
      //uploading data
      await candidate.set({
        "Name":candidateData["Name"].toString(),"Age":candidateData["Age"],"adharnum":candidateData["adharnum"],
        "party":candidateData["party"],"email":candidateData["email"],
        "phonenum":candidateData["phonenum"],"district":candidateData["district"],"state":candidateData["state"],
        "address":candidateData["address"],"dob":candidateData["dob"],
      });
      //clearing controllers
      if (kDebugMode) {
        print('succcessssssssssss');
      }
    }catch(e){
      adharBarOff();
      if (kDebugMode) {
        print('whaat went wronggg :::: $e');
      }
    }
  }



//------------------------------------------------------------------------------------------------------>>>>ElectionInfo
  late Future<List<FirebaseFile>> futureFiles;
  late int winnervotes = 0;
  late String winner = '';
  String? download;
  // late int row = 5;
  // late int col = 5;

  void initialize(String electionName){
    futureFiles = FirebaseApi.listAll('electionimages/$electionName/partyimages/candidates');
    winnervotes=0;
    winner = '';
    candidateset.clear();
  }

  late int candidatesNum = 0;

  final Set<Candidates> candidateset = {}; // your data goes here

  void calculateLeader(Candidates candidates,int candidateNum) {
    //candidates number
    candidatesNum = candidateNum;
    // logic to decide the winner
    if(candidates.votes > winnervotes){
      winnervotes = candidates.votes;
      winner = candidates.name;
    }else if(candidates.votes == winnervotes){
      winner = '$winner & ${candidates.name}';
    }
    candidateset.add(candidates);
    Future.delayed(Duration.zero, () async {
      update();
    });

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

  //------------------------------------------------------------------->>>>>>>>>>> Sign out function
  Future<void> signOut() async {
    await Auth().signOut();
    Get.offAll(()=> const IntroLogin());
  }

}