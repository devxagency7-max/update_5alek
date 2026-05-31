import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @addApartment.
  ///
  /// In en, this message translates to:
  /// **'Add Apartment'**
  String get addApartment;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Motareb'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for accommodation...'**
  String get searchHint;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @beds.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get beds;

  /// No description provided for @bed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get bed;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @double.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get double;

  /// No description provided for @triple.
  ///
  /// In en, this message translates to:
  /// **'Triple'**
  String get triple;

  /// No description provided for @quadruple.
  ///
  /// In en, this message translates to:
  /// **'Quadruple'**
  String get quadruple;

  /// No description provided for @apartmentPrice.
  ///
  /// In en, this message translates to:
  /// **'Apartment Price'**
  String get apartmentPrice;

  /// No description provided for @fullApartmentPrice.
  ///
  /// In en, this message translates to:
  /// **'Full Apartment Price'**
  String get fullApartmentPrice;

  /// No description provided for @totalChoices.
  ///
  /// In en, this message translates to:
  /// **'Total Choices'**
  String get totalChoices;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currency;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @selectRoom.
  ///
  /// In en, this message translates to:
  /// **'Select Room'**
  String get selectRoom;

  /// No description provided for @selectBed.
  ///
  /// In en, this message translates to:
  /// **'Select Bed'**
  String get selectBed;

  /// No description provided for @selectGuests.
  ///
  /// In en, this message translates to:
  /// **'Select Guests'**
  String get selectGuests;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @adults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get adults;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @infants.
  ///
  /// In en, this message translates to:
  /// **'Infants'**
  String get infants;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent'**
  String get codeSent;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'Code resent'**
  String get codeResent;

  /// No description provided for @codeVerified.
  ///
  /// In en, this message translates to:
  /// **'Code verified'**
  String get codeVerified;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Code invalid'**
  String get codeInvalid;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired'**
  String get codeExpired;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @homeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeScreen;

  /// No description provided for @searchScreen.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchScreen;

  /// No description provided for @bookingScreen.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get bookingScreen;

  /// No description provided for @profileScreen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreen;

  /// No description provided for @settingsScreen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreen;

  /// No description provided for @languageScreen.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageScreen;

  /// No description provided for @notificationsScreen.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsScreen;

  /// No description provided for @privacyPolicyScreen.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyScreen;

  /// No description provided for @termsOfServiceScreen.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceScreen;

  /// No description provided for @contactUsScreen.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsScreen;

  /// No description provided for @aboutUsScreen.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUsScreen;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @currentBookings.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentBookings;

  /// No description provided for @pastBookings.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastBookings;

  /// No description provided for @upcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingBookings;

  /// No description provided for @cancelledBookings.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledBookings;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingId;

  /// No description provided for @bookingDate.
  ///
  /// In en, this message translates to:
  /// **'Booking Date'**
  String get bookingDate;

  /// No description provided for @bookingStatus.
  ///
  /// In en, this message translates to:
  /// **'Booking Status'**
  String get bookingStatus;

  /// No description provided for @bookingTotal.
  ///
  /// In en, this message translates to:
  /// **'Booking Total'**
  String get bookingTotal;

  /// No description provided for @bookingPayment.
  ///
  /// In en, this message translates to:
  /// **'Booking Payment'**
  String get bookingPayment;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @paymentTotal.
  ///
  /// In en, this message translates to:
  /// **'Payment Total'**
  String get paymentTotal;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Success'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get paymentPending;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment Cancelled'**
  String get paymentCancelled;

  /// No description provided for @paymentRefunded.
  ///
  /// In en, this message translates to:
  /// **'Payment Refunded'**
  String get paymentRefunded;

  /// No description provided for @in_.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get in_;

  /// No description provided for @available247.
  ///
  /// In en, this message translates to:
  /// **'Available 24/7'**
  String get available247;

  /// No description provided for @jumpToPinned.
  ///
  /// In en, this message translates to:
  /// **'Jump to pinned'**
  String get jumpToPinned;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get errorOccurred;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Chat'**
  String get chatWelcome;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @youth.
  ///
  /// In en, this message translates to:
  /// **'Youth'**
  String get youth;

  /// No description provided for @girls.
  ///
  /// In en, this message translates to:
  /// **'Girls'**
  String get girls;

  /// No description provided for @noPropertiesFound.
  ///
  /// In en, this message translates to:
  /// **'No properties found'**
  String get noPropertiesFound;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get noSearchResults;

  /// No description provided for @noUniversitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No universities found'**
  String get noUniversitiesFound;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @featuredForYou.
  ///
  /// In en, this message translates to:
  /// **'Featured for you ✨'**
  String get featuredForYou;

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get recentlyAdded;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newLabel;

  /// No description provided for @noCategoryProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties in this category'**
  String get noCategoryProperties;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @verificationDetail.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get verificationDetail;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequired;

  /// No description provided for @verificationRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Sorry, you must verify your account first to book this property.'**
  String get verificationRequiredDesc;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @verificationTopHint.
  ///
  /// In en, this message translates to:
  /// **'Track your verification status in settings'**
  String get verificationTopHint;

  /// No description provided for @imageSizeError.
  ///
  /// In en, this message translates to:
  /// **'Image size must not exceed 20 MB'**
  String get imageSizeError;

  /// No description provided for @fileTypeError.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type. Please select JPG or PNG'**
  String get fileTypeError;

  /// No description provided for @imagePickError.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get imagePickError;

  /// No description provided for @completeDataError.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields'**
  String get completeDataError;

  /// No description provided for @savingData.
  ///
  /// In en, this message translates to:
  /// **'Saving data...'**
  String get savingData;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification request sent successfully'**
  String get verificationSent;

  /// No description provided for @sendError.
  ///
  /// In en, this message translates to:
  /// **'Error sending request'**
  String get sendError;

  /// No description provided for @verificationScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Verification'**
  String get verificationScreenTitle;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Under Review'**
  String get pendingTitle;

  /// No description provided for @pendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you. We are currently reviewing your data carefully. You will be notified of the result shortly.'**
  String get pendingMessage;

  /// No description provided for @verifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Verified Successfully'**
  String get verifiedTitle;

  /// No description provided for @verifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your account is now fully verified. You can enjoy all features and privileges.'**
  String get verifiedMessage;

  /// No description provided for @rejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Request Rejected'**
  String get rejectedTitle;

  /// No description provided for @rejectionReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason:'**
  String get rejectionReasonLabel;

  /// No description provided for @noReasonProvided.
  ///
  /// In en, this message translates to:
  /// **'No reason provided, please contact support.'**
  String get noReasonProvided;

  /// No description provided for @tryAgainAction.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainAction;

  /// No description provided for @personalInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoStep;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ensure data matches official ID'**
  String get personalInfoSubtitle;

  /// No description provided for @residenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Residence (District / Street)'**
  String get residenceLabel;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDateLabel;

  /// No description provided for @documentsStep.
  ///
  /// In en, this message translates to:
  /// **'Identity Documents'**
  String get documentsStep;

  /// No description provided for @documentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of your National ID (Original)'**
  String get documentsSubtitle;

  /// No description provided for @submitVerificationAction.
  ///
  /// In en, this message translates to:
  /// **'Submit Verification Request'**
  String get submitVerificationAction;

  /// No description provided for @governorateLabel.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorateLabel;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginAction;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @availableApartments.
  ///
  /// In en, this message translates to:
  /// **'Available Apartments'**
  String get availableApartments;

  /// No description provided for @propertiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Properties'**
  String propertiesCount(int count);

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @noPropertiesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No properties available'**
  String get noPropertiesAvailable;

  /// No description provided for @guestActionRestricted.
  ///
  /// In en, this message translates to:
  /// **'Guest action restricted'**
  String get guestActionRestricted;

  /// No description provided for @guestActionRestrictedDesc.
  ///
  /// In en, this message translates to:
  /// **'Please login to perform this action'**
  String get guestActionRestrictedDesc;

  /// No description provided for @signInNow.
  ///
  /// In en, this message translates to:
  /// **'Sign In Now'**
  String get signInNow;

  /// No description provided for @bedsSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Please select beds'**
  String get bedsSelectionError;

  /// No description provided for @fullApartment.
  ///
  /// In en, this message translates to:
  /// **'Full Apartment'**
  String get fullApartment;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @divided.
  ///
  /// In en, this message translates to:
  /// **'Divided'**
  String get divided;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @noFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Add properties to favorites to see them here'**
  String get noFavoritesDesc;

  /// No description provided for @searchFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get searchFilter;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @priceRangeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Price Range / Month ({currency})'**
  String priceRangeMonthly(String currency);

  /// No description provided for @housingType.
  ///
  /// In en, this message translates to:
  /// **'Housing Type'**
  String get housingType;

  /// No description provided for @bedInSharedRoom.
  ///
  /// In en, this message translates to:
  /// **'Bed in Shared Room'**
  String get bedInSharedRoom;

  /// No description provided for @singleRoom.
  ///
  /// In en, this message translates to:
  /// **'Single Room'**
  String get singleRoom;

  /// No description provided for @allowedGender.
  ///
  /// In en, this message translates to:
  /// **'Allowed Gender'**
  String get allowedGender;

  /// No description provided for @males.
  ///
  /// In en, this message translates to:
  /// **'Males'**
  String get males;

  /// No description provided for @females.
  ///
  /// In en, this message translates to:
  /// **'Females'**
  String get females;

  /// No description provided for @endDateError.
  ///
  /// In en, this message translates to:
  /// **'End date error'**
  String get endDateError;

  /// No description provided for @selectDatesError.
  ///
  /// In en, this message translates to:
  /// **'Please select dates'**
  String get selectDatesError;

  /// No description provided for @bookingRequest.
  ///
  /// In en, this message translates to:
  /// **'Booking Request'**
  String get bookingRequest;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @reviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Your request is under review'**
  String get reviewNotice;

  /// No description provided for @monthlyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Price'**
  String get monthlyPriceLabel;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your Data'**
  String get yourData;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @examplePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'05xxxxxxxx'**
  String get examplePhoneNumber;

  /// No description provided for @stayDuration.
  ///
  /// In en, this message translates to:
  /// **'Stay Duration'**
  String get stayDuration;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @selectStartMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Start Month'**
  String get selectStartMonth;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectEndMonth.
  ///
  /// In en, this message translates to:
  /// **'Select End Month'**
  String get selectEndMonth;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration: {months} months'**
  String totalDuration(int months);

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get identityVerification;

  /// No description provided for @dataProtectedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your data is protected'**
  String get dataProtectedNotice;

  /// No description provided for @fullNameInId.
  ///
  /// In en, this message translates to:
  /// **'Full Name in ID'**
  String get fullNameInId;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get fullNameHint;

  /// No description provided for @nationalIdNumber.
  ///
  /// In en, this message translates to:
  /// **'National ID Number'**
  String get nationalIdNumber;

  /// No description provided for @idNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter ID number'**
  String get idNumberHint;

  /// No description provided for @uploadIdPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload ID Photo'**
  String get uploadIdPhoto;

  /// No description provided for @idFrontFace.
  ///
  /// In en, this message translates to:
  /// **'Front Face'**
  String get idFrontFace;

  /// No description provided for @idBackFace.
  ///
  /// In en, this message translates to:
  /// **'Back Face'**
  String get idBackFace;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter notes'**
  String get notesHint;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Pay Deposit'**
  String get submitRequest;

  /// No description provided for @pickPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick photo'**
  String get pickPhotoHint;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @propertyVideo.
  ///
  /// In en, this message translates to:
  /// **'Property Video'**
  String get propertyVideo;

  /// No description provided for @noNumbersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No numbers available'**
  String get noNumbersAvailable;

  /// No description provided for @bookBeds.
  ///
  /// In en, this message translates to:
  /// **'Book Beds'**
  String get bookBeds;

  /// No description provided for @roomType.
  ///
  /// In en, this message translates to:
  /// **'Room Type: {type}'**
  String roomType(String type);

  /// No description provided for @requestedBedsCount.
  ///
  /// In en, this message translates to:
  /// **'Requested Beds Count'**
  String get requestedBedsCount;

  /// No description provided for @remainingBeds.
  ///
  /// In en, this message translates to:
  /// **'{count} Remaining Beds'**
  String remainingBeds(int count);

  /// No description provided for @bookApartmentFull.
  ///
  /// In en, this message translates to:
  /// **'Book Full Apartment'**
  String get bookApartmentFull;

  /// No description provided for @includesComponents.
  ///
  /// In en, this message translates to:
  /// **'Includes all rooms and facilities'**
  String get includesComponents;

  /// No description provided for @selectNeed.
  ///
  /// In en, this message translates to:
  /// **'Select Need'**
  String get selectNeed;

  /// No description provided for @selectUnitsFirst.
  ///
  /// In en, this message translates to:
  /// **'Select units first'**
  String get selectUnitsFirst;

  /// No description provided for @aboutPlace.
  ///
  /// In en, this message translates to:
  /// **'About Place'**
  String get aboutPlace;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully'**
  String get requestSentSuccess;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccess;

  /// No description provided for @googleLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Google Login Successful'**
  String get googleLoginSuccess;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @intro1Title.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Home'**
  String get intro1Title;

  /// No description provided for @intro1Desc.
  ///
  /// In en, this message translates to:
  /// **'Discover the best student housing options near your university.'**
  String get intro1Desc;

  /// No description provided for @intro2Title.
  ///
  /// In en, this message translates to:
  /// **'Easy Booking'**
  String get intro2Title;

  /// No description provided for @intro2Desc.
  ///
  /// In en, this message translates to:
  /// **'Book your room or bed seamlessly with just a few taps.'**
  String get intro2Desc;

  /// No description provided for @intro3Title.
  ///
  /// In en, this message translates to:
  /// **'Verified Listings'**
  String get intro3Title;

  /// No description provided for @intro3Desc.
  ///
  /// In en, this message translates to:
  /// **'All properties are verified for your safety and comfort.'**
  String get intro3Desc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @techSupport.
  ///
  /// In en, this message translates to:
  /// **'Tech Support'**
  String get techSupport;

  /// No description provided for @requiredDeposit.
  ///
  /// In en, this message translates to:
  /// **'Required Deposit'**
  String get requiredDeposit;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get noBookings;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @idVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Confirmation (Required)'**
  String get idVerificationTitle;

  /// No description provided for @idVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Please upload a clear photo of the front and back of your National ID to proceed.'**
  String get idVerificationDesc;

  /// No description provided for @idFront.
  ///
  /// In en, this message translates to:
  /// **'Front Side'**
  String get idFront;

  /// No description provided for @idBack.
  ///
  /// In en, this message translates to:
  /// **'Back Side'**
  String get idBack;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to Upload'**
  String get tapToUpload;

  /// No description provided for @uploadingImages.
  ///
  /// In en, this message translates to:
  /// **'Uploading images...'**
  String get uploadingImages;

  /// No description provided for @uploadIdError.
  ///
  /// In en, this message translates to:
  /// **'Please upload ID photos (front and back) to continue'**
  String get uploadIdError;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload images: {error}'**
  String uploadFailed(String error);

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Pay'**
  String get confirmAndPay;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// No description provided for @propertyLabel.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get propertyLabel;

  /// No description provided for @depositAmount.
  ///
  /// In en, this message translates to:
  /// **'Required Amount Now (Deposit)'**
  String get depositAmount;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount for Later'**
  String get remainingAmount;

  /// No description provided for @paymentRedirectNotice.
  ///
  /// In en, this message translates to:
  /// **'By confirming, you will be redirected to the secure payment page.'**
  String get paymentRedirectNotice;

  /// No description provided for @nearbyPlaces.
  ///
  /// In en, this message translates to:
  /// **'Nearby Places'**
  String get nearbyPlaces;

  /// No description provided for @nearbyUniversities.
  ///
  /// In en, this message translates to:
  /// **'Nearby Universities'**
  String get nearbyUniversities;

  /// No description provided for @paymentErrorPropertyReserved.
  ///
  /// In en, this message translates to:
  /// **'This property is currently being booked by someone else. Please try again in 5 minutes.'**
  String get paymentErrorPropertyReserved;

  /// No description provided for @paymentErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be initialized: {error}'**
  String paymentErrorGeneric(String error);

  /// No description provided for @paymentErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Selected property is no longer available.'**
  String get paymentErrorUnavailable;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to start finding your perfect home'**
  String get signupSubtitle;

  /// No description provided for @seeker.
  ///
  /// In en, this message translates to:
  /// **'Seeker'**
  String get seeker;

  /// No description provided for @seekerRole.
  ///
  /// In en, this message translates to:
  /// **'Looking for housing'**
  String get seekerRole;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @ownerRole.
  ///
  /// In en, this message translates to:
  /// **'Apartment Owner'**
  String get ownerRole;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @agreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to '**
  String get agreeTo;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Welcome'**
  String get accountCreatedSuccess;

  /// No description provided for @agreeTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to terms and conditions to continue'**
  String get agreeTermsError;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Prices and Payment Mechanism'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'The \"Khaleek Areeb\" application offers a range of paid services aimed at facilitating the housing search and advertising experience, such as premium property listings, paid subscriptions, and in-app advertising services.\n\nPrices vary based on the service or package selected, and the final price is clearly displayed to the user before completing the purchase within the application.\n\nAll payments are processed exclusively within the mobile application. The website does not provide purchasing or direct payment options, as its role is limited to displaying information and policies only.\n\nTo ensure the security of your financial data, all transactions are processed through a secured and certified electronic payment company (such as Paymob), using protection and encryption systems that guarantee the confidentiality and security of your banking information.\n\nIf you have any inquiries regarding payment or prices, you can contact us via the contact details provided within the application or website.'**
  String get privacyPolicyContent;

  /// No description provided for @websiteTitle.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteTitle;

  /// No description provided for @websiteContent.
  ///
  /// In en, this message translates to:
  /// **'For more information and details, you can visit our website.'**
  String get websiteContent;

  /// No description provided for @refundPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Refund Policy'**
  String get refundPolicyTitle;

  /// No description provided for @refundPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Users may request a refund within 7 days if the paid service has not been delivered or activated.\n\nRefund requests are reviewed by the Khaleek Areb support team.\n\nIf the refund request is approved, the amount will be returned to the original payment method within 3–7 business days.\n\nRefunds are not applicable if the service has already been delivered or used.\n\nFor refund requests, please contact us via email.'**
  String get refundPolicyContent;

  /// No description provided for @contactInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfoTitle;

  /// No description provided for @contactInfoContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions or refund requests, please contact us:\n\nEmail: devx.agency7@gmail.com\nPhone: 01026064819'**
  String get contactInfoContent;

  /// No description provided for @businessAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddressTitle;

  /// No description provided for @businessAddressContent.
  ///
  /// In en, this message translates to:
  /// **'Khaleek Areb\nCairo, Egypt'**
  String get businessAddressContent;

  /// No description provided for @aboutAppTitle.
  ///
  /// In en, this message translates to:
  /// **'About Khaleek Areb'**
  String get aboutAppTitle;

  /// No description provided for @aboutAppContent.
  ///
  /// In en, this message translates to:
  /// **'Khaleek Areb is a platform that helps university students find nearby accommodation and rental properties across Egypt.\n\nThe platform connects students with property owners to simplify the housing search process.'**
  String get aboutAppContent;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email and we will send you a secure link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent successfully!'**
  String get resetEmailSent;

  /// No description provided for @noInboxSupportPrefix.
  ///
  /// In en, this message translates to:
  /// **'If your email does not have an inbox to receive emails, you can '**
  String get noInboxSupportPrefix;

  /// No description provided for @contactUsAction.
  ///
  /// In en, this message translates to:
  /// **'contact us'**
  String get contactUsAction;

  /// No description provided for @noInboxSupportSuffix.
  ///
  /// In en, this message translates to:
  /// **' directly to help you change your password.'**
  String get noInboxSupportSuffix;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action is irreversible and all your bookings and user data will be wiped out.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during account deletion. You may need to log out, log in again to protect your data, and try again.'**
  String get deleteAccountError;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get sendReport;

  /// No description provided for @reportEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please write the report details'**
  String get reportEmptyError;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report sent successfully'**
  String get reportSuccess;

  /// No description provided for @reportSendError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sending the report, please try again'**
  String get reportSendError;

  /// No description provided for @reportIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a Report or Complaint'**
  String get reportIssueTitle;

  /// No description provided for @reportIssueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you encounter any problem or have a complaint, please send details and technical support will respond shortly.'**
  String get reportIssueSubtitle;

  /// No description provided for @reportDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Complaint or Report Details'**
  String get reportDetailsLabel;

  /// No description provided for @reportHintText.
  ///
  /// In en, this message translates to:
  /// **'Write here the details of the problem or report in detail...'**
  String get reportHintText;

  /// No description provided for @submitReportButton.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get submitReportButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
