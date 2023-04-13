import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:election/services/IntoLogin.dart';
import 'package:election/services/Pickelection.dart';
import 'package:election/services/VerifyEmail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../services/Auth.dart';
import '../utils/Constants.dart';

class AuthController extends GetxController{

  bool isloading = false;
  bool successAddUser = false;

  @override
  void onInit() {
    isloading = false;
    successAddUser =false;
    super.onInit();
  }

  //create user metheod using firebase auth
  Future<void> createUserWithEmailAndPassword(Map<String,dynamic> userData,bool admin) async {
    loadingbar();
    try {
      if(successAddUser == true){
        await Auth().createUserwithEmailAndPassword(email:userData['e-mail']!, password:userData['password']!);
        if(Auth().currentuser == null){
          Get.snackbar('Not Authenticated','Failed to do the task' );
        }else if(Auth().currentuser!.emailVerified){
          Get.offAll(()=>  Pickelec(admin:admin));
        }else{
          Get.offAll(()=>const VerifyEmail());
        }
      }else{
        Get.snackbar('Error signing in','try again after some time');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('firebase auth exception ::: $e');
      }
      Get.snackbar('error occured', '$e');
      loadingbaroff();
    }
    loadingbaroff();
  }

  //cloud firestore using firestore
  final CollectionReference admins = FirebaseFirestore.instance.collection('Admins');
  final CollectionReference voters = FirebaseFirestore.instance.collection('voters');

  //add user
  Future<void>addUser(Map<String,dynamic> userData,bool admin)async{
    loadingbar();
    if(admin == true){ // check if adding data to admins or voters
      try{

        await admins.doc(userData['e-mail']).set({
          "Name":userData['Name'],"e-mail":userData['e-mail'],"adhar":userData['adhar'],
          "phone":userData['phone'],"Admin":userData['Admin'],
        });
        elecbox.write('userdata',userData);
        successAddUser = true;
      }catch(err){
        if (kDebugMode) {
          print('add user error ::: $err');
        }
        Get.snackbar('Error signing in','try again after some time');
        loadingbaroff();
      }

    }else{
      //add data to voters if admins is false
      try{

        await voters.doc(userData['e-mail']).set({
          "Name":userData['Name'],"e-mail":userData['e-mail'],"adhar":userData['adhar'],
          "phone":userData['phone'],"Admin":userData['Admin'],"state":userData['state'],"district":userData['district'],
        });
        elecbox.write('userdata',userData);
        successAddUser = true;

      }catch(err){
        if (kDebugMode) {
          print('add user error ::: $err');
          Get.snackbar('Error signing in','try again after some time');
          loadingbaroff();
        }
      }
    }
    update();
    loadingbaroff();
  }

  //sign in with email and password
  Future<void> signInWithEmailAndPassword(String email,String password, bool admin) async {
    loadingbar();
    if(admin == true){
      try {
        loadingbar();
        await Auth().signInwithEmailAndPassword(email: email, password:password);
        if(elecbox.read('userdata') != null){
          elecbox.remove('userdata');
        }else{
          loadingbaroff();
        }
        if(Auth().currentuser == null){
          Get.snackbar('Not Authenticated','Either password or email is wrong' );
        }else{
          if(Auth().currentuser!.emailVerified){
            checkAdmin(Auth().currentuser!.email!);//here we use weather it is admin  or not
          }else{
            Get.offAll(()=>const VerifyEmail());
          }
        }
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print('sign in failed:::: $e');
          Get.snackbar('database exception', '$e');
        }
        loadingbaroff();
      }
    }else{
      try {
        loadingbar();
        await Auth().signInwithEmailAndPassword(email: email, password:password);
        if(elecbox.read('userdata') != null){
          elecbox.remove('userdata');
        }
        if(Auth().currentuser == null){
          Get.snackbar('Not Authenticated','Either password or email is wrong' );
        }else{
          if(Auth().currentuser!.emailVerified){
            checkVoter(Auth().currentuser!.email!);//here we use weather it is admin  or not
          }else{
            Get.offAll(()=>const VerifyEmail());
          }
        }
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print('sign in failed:::: $e');
          Get.snackbar('database exception', '$e');
        }
        loadingbaroff();
      }
    }
    loadingbaroff();
  }


  Future<void> checkAdmin(String email) async {
    bool isAdmin = false;
    if (kDebugMode) {
      print("this is status : $isAdmin");
    }
    try{
      loadingbar();
      final DocumentSnapshot admins = await FirebaseFirestore.instance
          .collection('Admins')
          .doc(Auth().currentuser!.email)
          .get();

      if(admins.data() != null){
        isAdmin = admins.get("Admin");
        if (kDebugMode) {
          print("this is status : $isAdmin");
        }
      }else{
        loadingbaroff();
        Auth().signOut();
        Get.snackbar("error","failed to fetch data");
      }
    }catch(e){
      loadingbaroff();
      Get.snackbar("error"," cannot fetch details");
      Auth().signOut();
      Get.offAll(()=>const IntroLogin());
    }
    if (kDebugMode) {
      print("this is status before check : $isAdmin");
    }
    if(isAdmin == true){
      Get.offAll(()=> const Pickelec(admin: true));
    }else{
      if (kDebugMode) {
        print("this is status : $isAdmin");
      }
      Get.snackbar("not an admin","You are not an admin");
      Auth().signOut();
      Get.offAll(()=>const IntroLogin());
    }
    loadingbaroff();
  }
  Future<void> checkVoter(String email) async {
    bool isVoter = true;
    if (kDebugMode) {
      print("this is status : $isVoter");
    }
    try{
      loadingbar();
      final DocumentSnapshot voters = await FirebaseFirestore.instance
          .collection('voters')
          .doc(Auth().currentuser!.email)
          .get();

      if(voters.data() != null){
        isVoter = voters.get("Admin");
        if (kDebugMode) {
          print("this is status : $isVoter");
        }
      }else{
        loadingbaroff();
        Auth().signOut();
        Get.snackbar("error","failed to fetch data");
      }
    }catch(e){
      loadingbaroff();
      Get.snackbar("error"," cannot fetch details");
      Auth().signOut();
      Get.offAll(()=>const IntroLogin());
    }
    if (kDebugMode) {
      print("this is status before check : $isVoter");
    }
    if(isVoter == false){
      Get.offAll(()=> const Pickelec(admin: false));
    }else{
      if (kDebugMode) {
        print("this is status : $isVoter");
      }
      Get.snackbar("not a voter","You are not a voter");
      Auth().signOut();
      Get.offAll(()=>const IntroLogin());
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