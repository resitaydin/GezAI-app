// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GezAI';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueButton => 'Continue';

  @override
  String get gotIt => 'Got It';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get appTitle => 'GezAI';

  @override
  String get appDescription => 'AI-powered travel companion for Istanbul';

  @override
  String get authWelcomeBack => 'Welcome Back!';

  @override
  String get authPlanAdventure => 'Plan your next Istanbul adventure.';

  @override
  String get authEmailAddress => 'Email Address';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authOrContinueWith => 'Or continue with';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authNewToApp => 'New to app? ';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authCreateYourAccount => 'Create Your Account';

  @override
  String get authStartPlanning => 'Start planning your Istanbul adventure';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authPasswordStrengthWeak => 'Weak';

  @override
  String get authPasswordStrengthMedium => 'Medium';

  @override
  String get authPasswordStrengthGood => 'Good';

  @override
  String get authPasswordStrengthStrong => 'Strong';

  @override
  String get authAgreeToTerms => 'I agree to the Terms of Service ';

  @override
  String get authTermsOfService => 'Terms of Service';

  @override
  String get authSignInWithGoogle => 'Sign In with Google';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get authPleaseAgreeToTerms => 'Please agree to the Terms of Service';

  @override
  String get authForgotPasswordTitle => 'Forgot Password?';

  @override
  String get authResetInstructions =>
      'Enter your email and we\'ll send you a password reset link if it\'s associated with your account.';

  @override
  String get authEnterYourEmail => 'Enter your email';

  @override
  String get authSendResetLink => 'Send Reset Link';

  @override
  String get authBackToSignIn => 'Back to Sign In';

  @override
  String get authVerifyEmail => 'Verify Your Email';

  @override
  String authVerificationSentTo(String email) {
    return 'We\'ve sent a verification link to $email';
  }

  @override
  String get authClickLinkToVerify =>
      'Click the link in the email to verify your account';

  @override
  String get authResendEmail => 'Resend Email';

  @override
  String authResendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authWrongEmailGoBack => 'Wrong email? Go back';

  @override
  String get authVerificationEmailSent => 'Verification email sent!';

  @override
  String get authCheckYourEmail => 'Check Your Email';

  @override
  String get authResetLinkSent =>
      'If an account exists with your email, we\'ve sent a password reset link to your email address.';

  @override
  String get authDidntReceiveEmail => 'Didn\'t receive the email? ';

  @override
  String get authResendLink => 'Resend Link';

  @override
  String get validationEmailRequired => 'Please enter your email';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String get validationPasswordRequired => 'Please enter your password';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get validationNameRequired => 'Please enter your name';

  @override
  String get validationPasswordConfirmRequired =>
      'Please confirm your password';

  @override
  String get errorUserNotFound => 'No user found with this email address.';

  @override
  String get errorWrongPassword => 'Incorrect password.';

  @override
  String get errorInvalidEmail => 'Invalid email address.';

  @override
  String get errorUserDisabled => 'This account has been disabled.';

  @override
  String get errorEmailAlreadyInUse => 'This email address is already in use.';

  @override
  String get errorWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get errorOperationNotAllowed => 'This sign-in method is not enabled.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get errorNetworkRequestFailed =>
      'Network error. Please check your connection.';

  @override
  String get errorGoogleSignInCancelled => 'Google sign-in cancelled';

  @override
  String get errorGoogleSignInFailed => 'Google sign-in failed';

  @override
  String get errorUnknown => 'An unknown error occurred';

  @override
  String get errorInvalidCredential =>
      'The email or password you entered is incorrect.';

  @override
  String get errorExpiredActionCode =>
      'This link has expired. Please request a new one.';

  @override
  String get errorInvalidActionCode =>
      'This link is invalid. Please request a new one.';

  @override
  String get errorRequiresRecentLogin =>
      'Please sign in again to complete this action.';

  @override
  String get errorAccountExistsWithDifferentCredential =>
      'An account already exists with this email using a different sign-in method.';

  @override
  String get errorCredentialAlreadyInUse =>
      'This credential is already associated with another account.';

  @override
  String get errorResetPasswordFailed =>
      'Failed to reset password. Please try again.';

  @override
  String get welcomeTitle => 'Istanbul Explorer';

  @override
  String get welcomeTagline => 'Discover Istanbul Your Way';

  @override
  String get welcomeGetStarted => 'Get Started';

  @override
  String get welcomeAlreadyHaveAccount => 'I already have an account';

  @override
  String get welcomeTopPick => 'Top Pick';

  @override
  String get welcomeHistoricalPeninsula => 'Historical Peninsula';

  @override
  String welcomeRouteHours(int hours) {
    return '$hours-hour route';
  }

  @override
  String get navExplore => 'Explore';

  @override
  String get navRoutes => 'Routes';

  @override
  String get navAdvice => 'Advice';

  @override
  String get navSaved => 'Saved';

  @override
  String get navProfile => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDefaultName => 'Traveler';

  @override
  String get profileStatsRoutes => 'Routes';

  @override
  String get profileStatsSaved => 'Saved';

  @override
  String get profileStatsExplored => 'Explored';

  @override
  String get profileMenuEditProfile => 'Edit Profile';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuLanguage => 'Language';

  @override
  String get profileMenuHelp => 'Help & Support';

  @override
  String get profileMenuAbout => 'About GezAI';

  @override
  String get profileLanguageValue => 'English';

  @override
  String get profileAboutVersion => 'Version 1.0.0 (MVP)';

  @override
  String get profileAboutDescription =>
      'AI-powered travel companion\nfor exploring Istanbul';

  @override
  String get profileLogoutTitle => 'Sign Out?';

  @override
  String get profileLogoutMessage =>
      'Are you sure you want to sign out of your account?';

  @override
  String get profileLogoutButton => 'Sign Out';

  @override
  String get profileLogoutCancel => 'Cancel';

  @override
  String get profileLogoutConfirm => 'Sign Out';

  @override
  String get profileMenuLanguageTrailing => 'English';

  @override
  String get profileAboutButton => 'Got It';

  @override
  String profileComingSoon(String feature) {
    return '$feature coming soon!';
  }

  @override
  String get myRoutesTitle => 'My Routes';

  @override
  String get myRoutesSavedBadge => 'Saved';

  @override
  String get myRoutesSubtitle => 'Pick up where you left off';

  @override
  String get myRoutesEmptyTitle => 'No saved routes yet';

  @override
  String get myRoutesEmptySubtitle =>
      'Start exploring Istanbul and\nsave routes you want to try later!';

  @override
  String get myRoutesEmptyDescription =>
      'Start exploring Istanbul and\nsave routes you want to try later!';

  @override
  String get myRoutesDiscoverButton => 'Discover Routes';

  @override
  String get myRoutesErrorTitle => 'Failed to load routes';

  @override
  String get myRoutesLoadingError => 'Failed to load routes';

  @override
  String get myRoutesRetryButton => 'Retry';

  @override
  String get myRoutesRetry => 'Retry';

  @override
  String get myRoutesDeleteDialogTitle => 'Delete Route?';

  @override
  String get myRoutesDeleteTitle => 'Delete Route?';

  @override
  String myRoutesDeleteDialogMessage(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String myRoutesDeleteMessage(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get myRoutesCancelButton => 'Cancel';

  @override
  String get myRoutesDeleteButton => 'Delete';

  @override
  String get myRoutesDeleteSuccess => 'Route deleted successfully';

  @override
  String myRoutesDeleteFailed(String error) {
    return 'Failed to delete route: $error';
  }

  @override
  String myRoutesDeleteError(String error) {
    return 'Failed to delete route: $error';
  }

  @override
  String myRoutesLoadFailed(String error) {
    return 'Failed to load route: $error';
  }

  @override
  String myRoutesLoadError(String error) {
    return 'Failed to load route: $error';
  }

  @override
  String get transportWalkingName => 'Walking';

  @override
  String get transportWalkingDescription => 'Discover historic streets on foot';

  @override
  String get transportWalkingBestFor => 'Best for sightseeing';

  @override
  String get transportPublicTransitName => 'Public Transit';

  @override
  String get transportPublicTransitDescription =>
      'Navigate the city by metro, bus, and tram';

  @override
  String get transportPublicTransitBestFor => 'Best for long distances';

  @override
  String get transportDrivingName => 'Driving';

  @override
  String get transportDrivingDescription => 'Explore Istanbul by car';

  @override
  String get transportDrivingBestFor => 'Best for flexibility';

  @override
  String get categoryMosques => 'Mosques';

  @override
  String get categoryMuseums => 'Museums';

  @override
  String get categoryParks => 'Parks';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryCafes => 'Cafes';

  @override
  String get categoryAttractions => 'Attractions';

  @override
  String get categoryHistorical => 'Historical Sites';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHotels => 'Hotels';

  @override
  String get categoryChurches => 'Churches';

  @override
  String get moodRomantic => 'Romantic';

  @override
  String get moodHistorical => 'Historical';

  @override
  String get moodRelaxing => 'Relaxing';

  @override
  String get moodFamily => 'Family';

  @override
  String get moodScenic => 'Scenic';

  @override
  String get moodFoodie => 'Foodie';

  @override
  String get moodPhotography => 'Photography';

  @override
  String get moodNature => 'Nature';

  @override
  String get moodAdventure => 'Adventure';

  @override
  String get moodCultural => 'Cultural';

  @override
  String get moodSpiritual => 'Spiritual';

  @override
  String get moodLocal => 'Local';

  @override
  String get moodHiddenGem => 'Hidden Gem';

  @override
  String get moodSunset => 'Sunset';

  @override
  String get moodMorning => 'Morning';

  @override
  String get moodNightlife => 'Nightlife';

  @override
  String get timePeriodMorning => 'Morning';

  @override
  String get timePeriodAfternoon => 'Afternoon';

  @override
  String get timePeriodEvening => 'Evening';

  @override
  String get timePeriodAnytime => 'Anytime';

  @override
  String get timePeriodMorningDesc => '6 AM - 12 PM';

  @override
  String get timePeriodAfternoonDesc => '12 PM - 6 PM';

  @override
  String get timePeriodEveningDesc => '6 PM - 12 AM';

  @override
  String get timePeriodAnytimeDesc => 'Flexible timing';

  @override
  String get defaultCategoriesHint => 'Museums, Cafes';

  @override
  String get defaultMoodsHint => 'Relaxing, Scenic';

  @override
  String get defaultDurationHint => 'Morning, Anytime';

  @override
  String get defaultTransportHint => 'Walking';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get routeLoadingTitle => 'Building Your Trip';

  @override
  String routeLoadingStep(int step) {
    return 'Step $step';
  }

  @override
  String get routeLoadingStatus => 'LOADING...';

  @override
  String get routeLoadingPlacesConsidering => 'Places we\'re considering';

  @override
  String get routeLoadingStep1Message => 'Discovering hidden gems... 💎';

  @override
  String get routeLoadingStep2Message => 'Optimizing your route... 🗺️';

  @override
  String get routeLoadingStep3Message => 'Adding local insights... ✨';

  @override
  String get routeLoadingStep1Label =>
      'Finding amazing places based on your preferences';

  @override
  String get routeLoadingStep2Label =>
      'Optimizing your route for the best experience';

  @override
  String get routeLoadingStep3Label =>
      'Adding local insights and recommendations';

  @override
  String get searchBarPlaceholder => 'Where do you want to explore?';

  @override
  String get routeSaved => 'Route saved';

  @override
  String get routeUnsaved => 'Route removed from saved';

  @override
  String get cannotSaveRoute => 'Cannot save route';

  @override
  String get failedToSaveRoute => 'Failed to save route';

  @override
  String get noRouteYet => 'No Route Yet';

  @override
  String get createFirstRoute =>
      'Start exploring Istanbul and create your first personalized route!';

  @override
  String get createYourRoute => 'Create Your Route';

  @override
  String get saved => 'Saved';

  @override
  String get startRoute => 'Start Route';

  @override
  String stopsCount(int count) {
    return '$count Stops';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterWalking => 'Walking';

  @override
  String get filterTransit => 'Transit';

  @override
  String get filterDriving => 'Driving';

  @override
  String get transportDrive => 'Drive';

  @override
  String get transportTransit => 'Transit';

  @override
  String get transportWalk => 'Walk';

  @override
  String placesCount(int count) {
    return '$count Places';
  }

  @override
  String get viewRoute => 'View Route';

  @override
  String get preparingRoute => 'Preparing route...';

  @override
  String get exploreRoute => 'Explore Route';

  @override
  String get categorySeaside => 'Seaside';

  @override
  String get categoryMosque => 'Mosque';

  @override
  String get categoryScenic => 'Scenic';

  @override
  String get categoryLocal => 'Local';

  @override
  String get categoryCafe => 'Cafe';

  @override
  String get categoryRestaurant => 'Restaurant';

  @override
  String get categoryPark => 'Park';

  @override
  String get categoryMuseum => 'Museum';

  @override
  String get categoryAttraction => 'Attraction';

  @override
  String get exploreCategories => 'Categories';

  @override
  String get exploreMood => 'Mood';

  @override
  String get exploreDuration => 'Duration';

  @override
  String get exploreTransport => 'Transport';

  @override
  String get createMyRoute => 'Create My Route';

  @override
  String get selectCategories => 'Select Categories';

  @override
  String get choosePlacesToExplore => 'Choose places you want to explore';

  @override
  String get clear => 'Clear';

  @override
  String categorySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'categories selected',
      one: 'category selected',
    );
    return '$_temp0';
  }

  @override
  String get applySelection => 'Apply Selection';

  @override
  String get moodTitle => 'What\'s your mood today?';

  @override
  String get moodSubtitle => 'We\'ll curate Istanbul just for you.';

  @override
  String moodSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'moods selected',
      one: 'mood selected',
    );
    return '$_temp0';
  }

  @override
  String get applyMood => 'Apply Mood';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get durationTitle => 'Duration';

  @override
  String get hourSingular => 'hour';

  @override
  String get hourPlural => 'hours';

  @override
  String get hourAbbr => 'h';

  @override
  String get applyDuration => 'Apply';

  @override
  String get transportTitle => 'How will you\nget around?';

  @override
  String get transportSubtitle =>
      'Choose your preferred way to explore Istanbul.';

  @override
  String get applyTransport => 'Apply Transport';

  @override
  String get curatedRoutes => 'Curated Routes';

  @override
  String get curatedRoutesSubtitle =>
      'Handpicked experiences curated by locals';

  @override
  String get somethingWentWrong => 'Oops! Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noRoutesFound => 'No routes found';

  @override
  String get noRoutesFoundSubtitle =>
      'Try selecting a different filter\nto discover more routes';

  @override
  String get showAllRoutes => 'Show All Routes';

  @override
  String get routeReady => 'Your Route is Ready!';

  @override
  String get routeReadySubtitle =>
      'We\'ve crafted the perfect itinerary based on your preferences';

  @override
  String get placesLabel => 'Places';

  @override
  String get durationLabel => 'Duration';

  @override
  String get kmLabel => 'km';

  @override
  String get viewMyRoute => 'View My Route';

  @override
  String get tripPlanner => 'TRIP PLANNER';

  @override
  String get suggestedItineraries => 'SUGGESTED ITINERARIES';

  @override
  String get aiCraftingRoute => 'AI is crafting your route...';

  @override
  String get findingBestSpots => 'Finding the best spots...';

  @override
  String get personalizingJourney => 'Personalizing your journey...';

  @override
  String get enrichingDetails => 'Enriching place details...';

  @override
  String get fetchingPhotos => 'Fetching photos & ratings...';

  @override
  String get finalizingItinerary => 'Finalizing your itinerary...';

  @override
  String get analyzingPreferences => 'Analyzing your preferences';

  @override
  String get selectingLocations => 'Selecting perfect locations';

  @override
  String get creatingSequence => 'Creating optimal sequence';

  @override
  String get gettingRealtimeData => 'Getting real-time data';

  @override
  String get loadingPlaceInfo => 'Loading place information';

  @override
  String get almostReady => 'Almost ready!';

  @override
  String get openNow => 'OPEN NOW';

  @override
  String get aboutSection => 'About';

  @override
  String get noDescriptionAvailable => 'No description available.';

  @override
  String get unableToLoadPlaceDetails => 'Unable to load place details';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get termsReadCarefully => 'Please read carefully';

  @override
  String get termsLoadFailed =>
      'Failed to load Terms of Service. Please try again later.';

  @override
  String get snackbarPasswordRequirements =>
      'Please meet all password requirements';

  @override
  String get snackbarPasswordResetSuccess => 'Password reset successfully!';

  @override
  String get snackbarAtLeastTwoStops =>
      'At least 2 stops are required to start navigation';

  @override
  String get snackbarCouldNotOpenMaps => 'Could not open Google Maps';

  @override
  String get snackbarFailedGenerateLink => 'Failed to generate route link';

  @override
  String get snackbarRouteTakingLonger =>
      'Route generation is taking longer than expected...';

  @override
  String get snackbarErrorOccurred => 'An error occurred';

  @override
  String get snackbarFailedLoadRouteDetails => 'Failed to load route details';
}
