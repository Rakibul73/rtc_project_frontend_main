import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rtc_project_fronend/constants/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider extends ChangeNotifier {
  var _userProfileImageUrl = '';
  var _username = '';
  var _firstname = '';
  var _lastname = '';
  var _email = '';
  var _address = '';
  var _areaOfExpertise = '';
  var _experienceInResearch = '';
  var _highestAcademicQualificationCountry = '';
  var _highestAcademicQualificationUniversity = '';
  var _highestAcademicQualificationYear = '';
  var _phone = '';
  var _profilePicLocation = '';
  var _roleId = 0;
  var _salaryScale = '';
  var _teaching = '';
  var _totalNumberOfCompleteProjects = 0;
  var _totalNumberOfCompletePublications = 0;
  var _ongoingProjects = 0;
  var _userId = 0;

  String get userProfileImageUrl => _userProfileImageUrl;
  String get username => _username;
  String get firstname => _firstname;
  String get lastname => _lastname;
  String get email => _email;
  String get address => _address;
  String get areaOfExpertise => _areaOfExpertise;
  String get experienceInResearch => _experienceInResearch;
  String get highestAcademicQualificationCountry => _highestAcademicQualificationCountry;
  String get highestAcademicQualificationUniversity => _highestAcademicQualificationUniversity;
  String get highestAcademicQualificationYear => _highestAcademicQualificationYear;
  String get phone => _phone;
  String get profilePicLocation => _profilePicLocation;
  int get roleId => _roleId;
  String get salaryScale => _salaryScale;
  String get teaching => _teaching;
  int get totalNumberOfCompleteProjects => _totalNumberOfCompleteProjects;
  int get totalNumberOfCompletePublications => _totalNumberOfCompletePublications;
  int get ongoingProjects => _ongoingProjects;
  int get userId => _userId;

  // get function for any key
  Future<String?> getFromSharedPref(String key) async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString(key) ?? '';
  }

  Future<void> loadAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    _username = sharedPref.getString(StorageKeys.username) ?? '';
    _firstname = sharedPref.getString(StorageKeys.firstname) ?? '';
    _lastname = sharedPref.getString(StorageKeys.lastname) ?? '';
    _userProfileImageUrl = sharedPref.getString(StorageKeys.userProfileImageUrl) ?? '';
    _email = sharedPref.getString(StorageKeys.email) ?? '';
    _address = sharedPref.getString(StorageKeys.address) ?? '';
    _areaOfExpertise = sharedPref.getString(StorageKeys.areaOfExpertise) ?? '';
    _experienceInResearch = sharedPref.getString(StorageKeys.experienceInResearch) ?? '';
    _highestAcademicQualificationCountry = sharedPref.getString(StorageKeys.highestAcademicQualificationCountry) ?? '';
    _highestAcademicQualificationUniversity = sharedPref.getString(StorageKeys.highestAcademicQualificationUniversity) ?? '';
    _highestAcademicQualificationYear = sharedPref.getString(StorageKeys.highestAcademicQualificationYear) ?? '';
    _phone = sharedPref.getString(StorageKeys.phone) ?? '';
    _profilePicLocation = sharedPref.getString(StorageKeys.profilePicLocation) ?? '';
    _roleId = sharedPref.getInt(StorageKeys.roleId) ?? 0;
    _salaryScale = sharedPref.getString(StorageKeys.salaryScale) ?? '';
    _teaching = sharedPref.getString(StorageKeys.teaching) ?? '';
    _totalNumberOfCompleteProjects = sharedPref.getInt(StorageKeys.totalNumberOfCompleteProjects) ?? 0;
    _totalNumberOfCompletePublications = sharedPref.getInt(StorageKeys.totalNumberOfCompletePublications) ?? 0;
    _ongoingProjects = sharedPref.getInt(StorageKeys.ongoingProjects) ?? 0;
    _userId = sharedPref.getInt(StorageKeys.userId) ?? 0;

    notifyListeners();
  }

  Future<void> setUserDataAsync({
    String? userProfileImageUrl,
    String? username,
    String? firstname,
    String? lastname,
    String? email,
    String? address,
    String? areaOfExpertise,
    String? experienceInResearch,
    String? highestAcademicQualificationCountry,
    String? highestAcademicQualificationUniversity,
    String? highestAcademicQualificationYear,
    String? phone,
    String? profilePicLocation,
    int? roleId,
    String? salaryScale,
    String? teaching,
    int? totalNumberOfCompleteProjects,
    int? totalNumberOfCompletePublications,
    int? ongoingProjects,
    int? userId,
  }) async {
    final sharedPref = await SharedPreferences.getInstance();
    var shouldNotify = false;

    if (userProfileImageUrl != null && userProfileImageUrl != _userProfileImageUrl) {
      _userProfileImageUrl = userProfileImageUrl;
      await sharedPref.setString(StorageKeys.userProfileImageUrl, _userProfileImageUrl);
      shouldNotify = true;
    }

    if (username != null && username != _username) {
      _username = username;
      await sharedPref.setString(StorageKeys.username, _username);
      shouldNotify = true;
    }

    if (firstname != null && firstname != _firstname) {
      _firstname = firstname;
      await sharedPref.setString(StorageKeys.firstname, _firstname);
      shouldNotify = true;
    }

    if (lastname != null && lastname != _lastname) {
      _lastname = lastname;
      await sharedPref.setString(StorageKeys.lastname, _lastname);
      shouldNotify = true;
    }

    if (email != null && email != _email) {
      _email = email;
      await sharedPref.setString(StorageKeys.email, _email);
      shouldNotify = true;
    }

    if (address != null && address != _address) {
      _address = address;
      await sharedPref.setString(StorageKeys.address, _address);
      shouldNotify = true;
    }

    if (areaOfExpertise != null && areaOfExpertise != _areaOfExpertise) {
      _areaOfExpertise = areaOfExpertise;
      await sharedPref.setString(StorageKeys.areaOfExpertise, _areaOfExpertise);
      shouldNotify = true;
    }

    if (experienceInResearch != null && experienceInResearch != _experienceInResearch) {
      _experienceInResearch = experienceInResearch;
      await sharedPref.setString(StorageKeys.experienceInResearch, _experienceInResearch);
      shouldNotify = true;
    }

    if (highestAcademicQualificationCountry != null && highestAcademicQualificationCountry != _highestAcademicQualificationCountry) {
      _highestAcademicQualificationCountry = highestAcademicQualificationCountry;
      await sharedPref.setString(StorageKeys.highestAcademicQualificationCountry, _highestAcademicQualificationCountry);
      shouldNotify = true;
    }

    if (highestAcademicQualificationUniversity != null && highestAcademicQualificationUniversity != _highestAcademicQualificationUniversity) {
      _highestAcademicQualificationUniversity = highestAcademicQualificationUniversity;
      await sharedPref.setString(StorageKeys.highestAcademicQualificationUniversity, _highestAcademicQualificationUniversity);
      shouldNotify = true;
    }

    if (highestAcademicQualificationYear != null && highestAcademicQualificationYear != _highestAcademicQualificationYear) {
      _highestAcademicQualificationYear = highestAcademicQualificationYear;
      await sharedPref.setString(StorageKeys.highestAcademicQualificationYear, _highestAcademicQualificationYear);
      shouldNotify = true;
    }

    if (phone != null && phone != _phone) {
      _phone = phone;
      await sharedPref.setString(StorageKeys.phone, _phone);
      shouldNotify = true;
    }

    if (profilePicLocation != null && profilePicLocation != _profilePicLocation) {
      _profilePicLocation = profilePicLocation;
      await sharedPref.setString(StorageKeys.profilePicLocation, _profilePicLocation);
      shouldNotify = true;
    }

    if (roleId != null && roleId != _roleId) {
      _roleId = roleId;
      await sharedPref.setInt(StorageKeys.roleId, _roleId);
      shouldNotify = true;
    }

    if (salaryScale != null && salaryScale != _salaryScale) {
      _salaryScale = salaryScale;
      await sharedPref.setString(StorageKeys.salaryScale, _salaryScale);
      shouldNotify = true;
    }

    if (teaching != null && teaching != _teaching) {
      _teaching = teaching;
      await sharedPref.setString(StorageKeys.teaching, _teaching);
      shouldNotify = true;
    }

    if (totalNumberOfCompleteProjects != null && totalNumberOfCompleteProjects != _totalNumberOfCompleteProjects) {
      _totalNumberOfCompleteProjects = totalNumberOfCompleteProjects;
      await sharedPref.setInt(StorageKeys.totalNumberOfCompleteProjects, _totalNumberOfCompleteProjects);
      shouldNotify = true;
    }

    if (totalNumberOfCompletePublications != null && totalNumberOfCompletePublications != _totalNumberOfCompletePublications) {
      _totalNumberOfCompletePublications = totalNumberOfCompletePublications;
      await sharedPref.setInt(StorageKeys.totalNumberOfCompletePublications, _totalNumberOfCompletePublications);
      shouldNotify = true;
    }

    if (ongoingProjects != null && ongoingProjects != _ongoingProjects) {
      _ongoingProjects = ongoingProjects;
      await sharedPref.setInt(StorageKeys.ongoingProjects, _ongoingProjects);
      shouldNotify = true;
    }

    if (userId != null && userId != _userId) {
      _userId = userId;
      await sharedPref.setInt(StorageKeys.userId, _userId);
      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> clearUserDataAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    await sharedPref.remove(StorageKeys.username);
    await sharedPref.remove(StorageKeys.firstname);
    await sharedPref.remove(StorageKeys.lastname);
    await sharedPref.remove(StorageKeys.userProfileImageUrl);
    await sharedPref.remove(StorageKeys.email);
    await sharedPref.remove(StorageKeys.address);
    await sharedPref.remove(StorageKeys.areaOfExpertise);
    await sharedPref.remove(StorageKeys.experienceInResearch);
    await sharedPref.remove(StorageKeys.highestAcademicQualificationCountry);
    await sharedPref.remove(StorageKeys.highestAcademicQualificationUniversity);
    await sharedPref.remove(StorageKeys.highestAcademicQualificationYear);
    await sharedPref.remove(StorageKeys.phone);
    await sharedPref.remove(StorageKeys.profilePicLocation);
    await sharedPref.remove(StorageKeys.roleId);
    await sharedPref.remove(StorageKeys.salaryScale);
    await sharedPref.remove(StorageKeys.teaching);
    await sharedPref.remove(StorageKeys.totalNumberOfCompleteProjects);
    await sharedPref.remove(StorageKeys.totalNumberOfCompletePublications);
    await sharedPref.remove(StorageKeys.ongoingProjects);
    await sharedPref.remove(StorageKeys.userId);

    _userProfileImageUrl = '';
    _username = '';
    _firstname = '';
    _lastname = '';
    _email = '';
    _address = '';
    _areaOfExpertise = '';
    _experienceInResearch = '';
    _highestAcademicQualificationCountry = '';
    _highestAcademicQualificationUniversity = '';
    _highestAcademicQualificationYear = '';
    _phone = '';
    _profilePicLocation = '';
    _roleId = 0;
    _salaryScale = '';
    _teaching = '';
    _totalNumberOfCompleteProjects = 0;
    _totalNumberOfCompletePublications = 0;
    _ongoingProjects = 0;
    _userId = 0;

    notifyListeners();
  }

  bool isUserLoggedIn() {
    return _username.isNotEmpty;
    // implement to check if user is logged in with api
  }
}
