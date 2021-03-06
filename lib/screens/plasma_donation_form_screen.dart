import 'package:covid_app/constants/app_constants.dart';
import 'package:covid_app/global.dart';
import 'package:covid_app/providers/user_profile_provider.dart';
import 'package:covid_app/screens/otp_screen.dart';
import 'package:covid_app/services/auth_service.dart';
import 'package:covid_app/utils/date_formatter.dart';
import 'package:covid_app/widgets/blood_drop_logo.dart';
import 'package:covid_app/widgets/bottom_button.dart';
import 'package:covid_app/widgets/multi_select_dialog.dart';
import 'package:covid_app/widgets/text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// TODO: Make the code for this page a bit cleaner

class PlasmaDonationFormScreen extends StatefulWidget {
  @override
  _PlasmaDonationFormScreenState createState() =>
      _PlasmaDonationFormScreenState();
}

class _PlasmaDonationFormScreenState extends State<PlasmaDonationFormScreen> {
  // loading state variable
  bool _isLoading = false;

  // Text editing controllers
  TextEditingController _cityController = TextEditingController();
  TextEditingController _bloodGroupController = TextEditingController();
  TextEditingController _collegeController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Text Theme
    TextTheme textTheme = Theme.of(context).textTheme;
    // user profile provider
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);

    // Set text for controllers
    _cityController.text = userProfileProvider.userProfile.city ?? "";
    _bloodGroupController.text =
        userProfileProvider.userProfile.bloodGroup ?? "";
    _collegeController.text =
        userProfileProvider.userProfile.matesAffiliation ?? "";
    _stateController.text = userProfileProvider.userProfile.state ?? "";
    _dateController.text = DateFormatter.formatDate(
            userProfileProvider.userProfile.lastCovidPositiveDate) ??
        "";
    return WillPopScope(
      onWillPop: () {
        userProfileProvider.resetProvider();
        Navigator.pop(context);
        return null;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: BloodDropLogo(
                      dropType: "PLASMA",
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Plasma Donor",
                      style: textTheme.headline6,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32.0, 32, 32, 16),
                  child: TextBox(
                    hintText: "Name",
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    onChanged: (value) => userProfileProvider.updateName(value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextBox(
                    hintText: "Pin Code",
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (value) =>
                        userProfileProvider.updatePinCode(value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16, left: 32, right: 32, bottom: 0),
                  child: TextBox(
                    hintText: "State",
                    readOnly: true,
                    controller: _stateController,
                    onTap: () => _showSelectStateDialog(context),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  child: TextBox(
                    hintText: "City",
                    readOnly: true,
                    controller: _cityController,
                    onTap: userProfileProvider.userProfile.state == null
                        ? null
                        : () => _showSelectCityDialog(context),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextBox(
                    hintText: "Phone Number",
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) =>
                        userProfileProvider.updatePhoneNumber(value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  child: TextBox(
                    hintText: "Blood Group",
                    keyboardType: TextInputType.name,
                    controller: _bloodGroupController,
                    readOnly: true,
                    onTap: () => _showBloodGroupDialog(context),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextBox(
                    hintText: "Mates Affiliation",
                    readOnly: true,
                    controller: _collegeController,
                    onTap: () => _showSelectCollegeDialog(context),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 32,
                    right: 32,
                    bottom: 32,
                  ),
                  child: TextBox(
                    hintText: "Date of COVID positive report",
                    keyboardType: TextInputType.name,
                    readOnly: true,
                    controller: _dateController,
                    onTap: () => _selectDate(context),
                    suffixIcon: Icon(
                      Icons.date_range,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: BottomButton(
                    loadingState: _isLoading,
                    disabledState: false,
                    child: Text("Continue"),
                    onPressed: () =>
                        _onSubmitDetails(userProfileProvider, context),
                  ),
                ),
                SizedBox(height: 32)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showBloodGroupDialog(BuildContext context) {
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    return showDialog(
      context: context,
      builder: (context) => MultiSelectDialog(
        title: "Select your blood group",
        children: AppConstants.BLOOD_GROUP_LIST
            .map(
              (e) => MultiSelectDialogItem(
                text: e,
                onPressed: () {
                  userProfileProvider.updateBloodGroup(e);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _showSelectCollegeDialog(BuildContext context) {
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    return showDialog(
      context: context,
      builder: (context) => MultiSelectDialog(
        title: "Select your college name",
        children: AppConstants.MATES_AFFILIATION_LIST
            .map(
              (e) => MultiSelectDialogItem(
                text: e,
                onPressed: () {
                  userProfileProvider.updateCollegeName(e);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _showSelectCityDialog(BuildContext context) {
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    return showDialog(
      context: context,
      builder: (context) => MultiSelectDialog(
        title: "Select your city name",
        children: AppConstants
            .STATES_CITIES_MAP[userProfileProvider.userProfile.state]
            .map(
              (e) => MultiSelectDialogItem(
                text: e,
                onPressed: () {
                  userProfileProvider.updateCityName(e);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _showSelectStateDialog(BuildContext context) {
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    return showDialog(
      context: context,
      builder: (context) => MultiSelectDialog(
        title: "Select your state name",
        children: AppConstants.STATES_CITIES_MAP.keys
            .toList()
            .map(
              (e) => MultiSelectDialogItem(
                text: e,
                onPressed: () {
                  userProfileProvider.updateStateName(e);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      userProfileProvider.getLastCovidPositiveDate(picked);
    }
  }

  Future<void> _onSubmitDetails(
      UserProfileProvider userProfileProvider, BuildContext context) async {
    if (!userProfileProvider.validatePlasmaForm()) {
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter all the details.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
    setState(() {
      _isLoading = true;
    });

    /// OTP verification method
    return AuthService.signInWithPhone(
      "${userProfileProvider.userProfile.phoneNumber}",

      /// Callbacks
      onAutoPhoneVerificationCompleted: (AuthCredential credential) async {
        String _errorMessage = await AuthService.loginForDonors(
            credential, userProfileProvider.userProfile);
        // Conditions to validate error message
        if (_errorMessage == null) {
          userProfileProvider.resetProvider();
          Navigator.pushNamedAndRemoveUntil(
              context, '/confirmation_screen', (route) => false);
        }
        // Display error message in case of invalid OTP.
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
        }
      },

      /// Fired when auto phone verification gets failed
      onPhoneVerificationFailed: (FirebaseAuthException e) {
        logger.w(e.message);
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthService.getMessageFromErrorCode(e.code)),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      },

      /// Fired when the code is sent from server
      onPhoneCodeSent: (String verificationId, [int forceCodeResend]) async {
        // turn off the loading state of button upon successful login
        setState(() {
          _isLoading = false;
        });
        // Go to OTP screen to input the OTP and verify if entered OTP was correct
        String _errorMessage = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              verificationId: verificationId,
              fromDonorScreen: true,
            ),
          ),
        );
        logger..d("error message: $_errorMessage");
        //  If entered OTP is valid
        if (_errorMessage == null) {
          userProfileProvider.resetProvider();
          Navigator.pushNamedAndRemoveUntil(
              context, '/confirmation_screen', (route) => false);
        }
        // in case user has not entered OTP.
        else if (_errorMessage == "NOT_ENTERED") {
          return;
        }
        // Display error message in case of invalid OTP.
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
        }
      },
    );
  }
}
