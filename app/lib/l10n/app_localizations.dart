import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'GezAI'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get continueButton;

  /// No description provided for @gotIt.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get gotIt;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'GezAI'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul için yapay zeka destekli seyahat arkadaşı'**
  String get appDescription;

  /// No description provided for @authWelcomeBack.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldin!'**
  String get authWelcomeBack;

  /// No description provided for @authPlanAdventure.
  ///
  /// In tr, this message translates to:
  /// **'Bir sonraki İstanbul maceranı planla.'**
  String get authPlanAdventure;

  /// No description provided for @authEmailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresi'**
  String get authEmailAddress;

  /// No description provided for @authPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get authSignIn;

  /// No description provided for @authOrContinueWith.
  ///
  /// In tr, this message translates to:
  /// **'Veya şununla devam et'**
  String get authOrContinueWith;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Devam Et'**
  String get authContinueWithGoogle;

  /// No description provided for @authNewToApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamada yeni misin? '**
  String get authNewToApp;

  /// No description provided for @authCreateAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get authCreateAccount;

  /// No description provided for @authCreateYourAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını Oluştur'**
  String get authCreateYourAccount;

  /// No description provided for @authStartPlanning.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul maceranı planlamaya başla'**
  String get authStartPlanning;

  /// No description provided for @authFullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get authFullName;

  /// No description provided for @authConfirmPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Onayla'**
  String get authConfirmPassword;

  /// No description provided for @authPasswordStrengthWeak.
  ///
  /// In tr, this message translates to:
  /// **'Zayıf'**
  String get authPasswordStrengthWeak;

  /// No description provided for @authPasswordStrengthMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get authPasswordStrengthMedium;

  /// No description provided for @authPasswordStrengthGood.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get authPasswordStrengthGood;

  /// No description provided for @authPasswordStrengthStrong.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü'**
  String get authPasswordStrengthStrong;

  /// No description provided for @authAgreeToTerms.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet Şartları\'nı kabul ediyorum '**
  String get authAgreeToTerms;

  /// No description provided for @authTermsOfService.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet Şartları'**
  String get authTermsOfService;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get authSignInWithGoogle;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? '**
  String get authAlreadyHaveAccount;

  /// No description provided for @authPleaseAgreeToTerms.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen Hizmet Şartları\'nı kabul edin'**
  String get authPleaseAgreeToTerms;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni Unuttun mu?'**
  String get authForgotPasswordTitle;

  /// No description provided for @authResetInstructions.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı gir, hesabınla ilişkiliyse sana şifre sıfırlama bağlantısı gönderelim.'**
  String get authResetInstructions;

  /// No description provided for @authEnterYourEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı gir'**
  String get authEnterYourEmail;

  /// No description provided for @authSendResetLink.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama Bağlantısı Gönder'**
  String get authSendResetLink;

  /// No description provided for @authBackToSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Girişe Dön'**
  String get authBackToSignIn;

  /// No description provided for @authVerifyEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı Doğrula'**
  String get authVerifyEmail;

  /// No description provided for @authVerificationSentTo.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine doğrulama bağlantısı gönderdik'**
  String authVerificationSentTo(String email);

  /// No description provided for @authClickLinkToVerify.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını doğrulamak için e-postadaki bağlantıya tıkla'**
  String get authClickLinkToVerify;

  /// No description provided for @authResendEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postayı Tekrar Gönder'**
  String get authResendEmail;

  /// No description provided for @authResendInSeconds.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar gönder {seconds}s'**
  String authResendInSeconds(int seconds);

  /// No description provided for @authWrongEmailGoBack.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış e-posta mı? Geri dön'**
  String get authWrongEmailGoBack;

  /// No description provided for @authVerificationEmailSent.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama e-postası gönderildi!'**
  String get authVerificationEmailSent;

  /// No description provided for @authCheckYourEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı Kontrol Et'**
  String get authCheckYourEmail;

  /// No description provided for @authResetLinkSent.
  ///
  /// In tr, this message translates to:
  /// **'E-postanla ilişkili bir hesap varsa, e-posta adresine şifre sıfırlama bağlantısı gönderdik.'**
  String get authResetLinkSent;

  /// No description provided for @authDidntReceiveEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postayı almadın mı? '**
  String get authDidntReceiveEmail;

  /// No description provided for @authResendLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı Tekrar Gönder'**
  String get authResendLink;

  /// No description provided for @validationEmailRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-postanızı girin'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta adresi girin'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi girin'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @validationNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen adınızı girin'**
  String get validationNameRequired;

  /// No description provided for @validationPasswordConfirmRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi onaylayın'**
  String get validationPasswordConfirmRequired;

  /// No description provided for @errorUserNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongPassword.
  ///
  /// In tr, this message translates to:
  /// **'Hatalı şifre.'**
  String get errorWrongPassword;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta adresi.'**
  String get errorInvalidEmail;

  /// No description provided for @errorUserDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap devre dışı bırakılmış.'**
  String get errorUserDisabled;

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresi zaten kullanılıyor.'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır.'**
  String get errorWeakPassword;

  /// No description provided for @errorOperationNotAllowed.
  ///
  /// In tr, this message translates to:
  /// **'Bu giriş yöntemi etkin değil.'**
  String get errorOperationNotAllowed;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.'**
  String get errorTooManyRequests;

  /// No description provided for @errorNetworkRequestFailed.
  ///
  /// In tr, this message translates to:
  /// **'Ağ hatası. Lütfen bağlantınızı kontrol edin.'**
  String get errorNetworkRequestFailed;

  /// No description provided for @errorGoogleSignInCancelled.
  ///
  /// In tr, this message translates to:
  /// **'Google girişi iptal edildi'**
  String get errorGoogleSignInCancelled;

  /// No description provided for @errorGoogleSignInFailed.
  ///
  /// In tr, this message translates to:
  /// **'Google girişi başarısız oldu'**
  String get errorGoogleSignInFailed;

  /// No description provided for @errorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen bir hata oluştu'**
  String get errorUnknown;

  /// No description provided for @errorInvalidCredential.
  ///
  /// In tr, this message translates to:
  /// **'Girdiğiniz e-posta veya şifre hatalı.'**
  String get errorInvalidCredential;

  /// No description provided for @errorExpiredActionCode.
  ///
  /// In tr, this message translates to:
  /// **'Bu bağlantının süresi dolmuş. Lütfen yeni bir tane talep edin.'**
  String get errorExpiredActionCode;

  /// No description provided for @errorInvalidActionCode.
  ///
  /// In tr, this message translates to:
  /// **'Bu bağlantı geçersiz. Lütfen yeni bir tane talep edin.'**
  String get errorInvalidActionCode;

  /// No description provided for @errorRequiresRecentLogin.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlemi tamamlamak için lütfen tekrar giriş yapın.'**
  String get errorRequiresRecentLogin;

  /// No description provided for @errorAccountExistsWithDifferentCredential.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresiyle farklı bir giriş yöntemi kullanılarak oluşturulmuş bir hesap zaten var.'**
  String get errorAccountExistsWithDifferentCredential;

  /// No description provided for @errorCredentialAlreadyInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu kimlik bilgisi zaten başka bir hesapla ilişkilendirilmiş.'**
  String get errorCredentialAlreadyInUse;

  /// No description provided for @errorResetPasswordFailed.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlanamadı. Lütfen tekrar deneyin.'**
  String get errorResetPasswordFailed;

  /// No description provided for @welcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul Rehberi'**
  String get welcomeTitle;

  /// No description provided for @welcomeTagline.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul\'u Kendi Tarzınla Keşfet'**
  String get welcomeTagline;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeAlreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabım var'**
  String get welcomeAlreadyHaveAccount;

  /// No description provided for @welcomeTopPick.
  ///
  /// In tr, this message translates to:
  /// **'En İyi Seçim'**
  String get welcomeTopPick;

  /// No description provided for @welcomeHistoricalPeninsula.
  ///
  /// In tr, this message translates to:
  /// **'Tarihi Yarımada'**
  String get welcomeHistoricalPeninsula;

  /// No description provided for @welcomeRouteHours.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saatlik rota'**
  String welcomeRouteHours(int hours);

  /// No description provided for @navExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get navExplore;

  /// No description provided for @navRoutes.
  ///
  /// In tr, this message translates to:
  /// **'Rotalar'**
  String get navRoutes;

  /// No description provided for @navAdvice.
  ///
  /// In tr, this message translates to:
  /// **'Öneri'**
  String get navAdvice;

  /// No description provided for @navSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı'**
  String get navSaved;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileDefaultName.
  ///
  /// In tr, this message translates to:
  /// **'Gezgin'**
  String get profileDefaultName;

  /// No description provided for @profileStatsRoutes.
  ///
  /// In tr, this message translates to:
  /// **'Rotalar'**
  String get profileStatsRoutes;

  /// No description provided for @profileStatsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get profileStatsSaved;

  /// No description provided for @profileStatsExplored.
  ///
  /// In tr, this message translates to:
  /// **'Keşfedilenler'**
  String get profileStatsExplored;

  /// No description provided for @profileMenuEditProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get profileMenuEditProfile;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get profileMenuLanguage;

  /// No description provided for @profileMenuHelp.
  ///
  /// In tr, this message translates to:
  /// **'Yardım ve Destek'**
  String get profileMenuHelp;

  /// No description provided for @profileMenuAbout.
  ///
  /// In tr, this message translates to:
  /// **'GezAI Hakkında'**
  String get profileMenuAbout;

  /// No description provided for @profileLanguageValue.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get profileLanguageValue;

  /// No description provided for @profileAboutVersion.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon 1.0.0 (MVP)'**
  String get profileAboutVersion;

  /// No description provided for @profileAboutDescription.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul\'u keşfetmek için\nyapay zeka destekli seyahat arkadaşı'**
  String get profileAboutDescription;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'**
  String get profileLogoutMessage;

  /// No description provided for @profileLogoutButton.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get profileLogoutButton;

  /// No description provided for @profileLogoutCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get profileLogoutCancel;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get profileLogoutConfirm;

  /// No description provided for @profileMenuLanguageTrailing.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get profileMenuLanguageTrailing;

  /// No description provided for @profileAboutButton.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get profileAboutButton;

  /// No description provided for @profileComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'{feature} yakında geliyor!'**
  String profileComingSoon(String feature);

  /// No description provided for @myRoutesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rotalarım'**
  String get myRoutesTitle;

  /// No description provided for @myRoutesSavedBadge.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get myRoutesSavedBadge;

  /// No description provided for @myRoutesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaldığın yerden devam et'**
  String get myRoutesSubtitle;

  /// No description provided for @myRoutesEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kaydedilmiş rota yok'**
  String get myRoutesEmptyTitle;

  /// No description provided for @myRoutesEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul\'u keşfetmeye başla ve\ndaha sonra denemek istediğin rotaları kaydet!'**
  String get myRoutesEmptySubtitle;

  /// No description provided for @myRoutesEmptyDescription.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul\'u keşfetmeye başla ve\ndaha sonra denemek istediğin rotaları kaydet!'**
  String get myRoutesEmptyDescription;

  /// No description provided for @myRoutesDiscoverButton.
  ///
  /// In tr, this message translates to:
  /// **'Rotaları Keşfet'**
  String get myRoutesDiscoverButton;

  /// No description provided for @myRoutesErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rotalar yüklenemedi'**
  String get myRoutesErrorTitle;

  /// No description provided for @myRoutesLoadingError.
  ///
  /// In tr, this message translates to:
  /// **'Rotalar yüklenemedi'**
  String get myRoutesLoadingError;

  /// No description provided for @myRoutesRetryButton.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get myRoutesRetryButton;

  /// No description provided for @myRoutesRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get myRoutesRetry;

  /// No description provided for @myRoutesDeleteDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rotayı Sil?'**
  String get myRoutesDeleteDialogTitle;

  /// No description provided for @myRoutesDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rotayı Sil?'**
  String get myRoutesDeleteTitle;

  /// No description provided for @myRoutesDeleteDialogMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" rotasını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'**
  String myRoutesDeleteDialogMessage(String title);

  /// No description provided for @myRoutesDeleteMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" rotasını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'**
  String myRoutesDeleteMessage(String title);

  /// No description provided for @myRoutesCancelButton.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get myRoutesCancelButton;

  /// No description provided for @myRoutesDeleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get myRoutesDeleteButton;

  /// No description provided for @myRoutesDeleteSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Rota başarıyla silindi'**
  String get myRoutesDeleteSuccess;

  /// No description provided for @myRoutesDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Rota silinemedi: {error}'**
  String myRoutesDeleteFailed(String error);

  /// No description provided for @myRoutesDeleteError.
  ///
  /// In tr, this message translates to:
  /// **'Rota silinemedi: {error}'**
  String myRoutesDeleteError(String error);

  /// No description provided for @myRoutesLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Rota yüklenemedi: {error}'**
  String myRoutesLoadFailed(String error);

  /// No description provided for @myRoutesLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Rota yüklenemedi: {error}'**
  String myRoutesLoadError(String error);

  /// No description provided for @transportWalkingName.
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüş'**
  String get transportWalkingName;

  /// No description provided for @transportWalkingDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tarihi sokakları yürüyerek keşfet'**
  String get transportWalkingDescription;

  /// No description provided for @transportWalkingBestFor.
  ///
  /// In tr, this message translates to:
  /// **'Gezinti için en uygun'**
  String get transportWalkingBestFor;

  /// No description provided for @transportPublicTransitName.
  ///
  /// In tr, this message translates to:
  /// **'Toplu Taşıma'**
  String get transportPublicTransitName;

  /// No description provided for @transportPublicTransitDescription.
  ///
  /// In tr, this message translates to:
  /// **'Metro, otobüs ve tramvayla şehri dolaş'**
  String get transportPublicTransitDescription;

  /// No description provided for @transportPublicTransitBestFor.
  ///
  /// In tr, this message translates to:
  /// **'Uzun mesafeler için en uygun'**
  String get transportPublicTransitBestFor;

  /// No description provided for @transportDrivingName.
  ///
  /// In tr, this message translates to:
  /// **'Araba'**
  String get transportDrivingName;

  /// No description provided for @transportDrivingDescription.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul\'u arabayla gezin'**
  String get transportDrivingDescription;

  /// No description provided for @transportDrivingBestFor.
  ///
  /// In tr, this message translates to:
  /// **'Esneklik için en uygun'**
  String get transportDrivingBestFor;

  /// No description provided for @categoryMosques.
  ///
  /// In tr, this message translates to:
  /// **'Camiler'**
  String get categoryMosques;

  /// No description provided for @categoryMuseums.
  ///
  /// In tr, this message translates to:
  /// **'Müzeler'**
  String get categoryMuseums;

  /// No description provided for @categoryParks.
  ///
  /// In tr, this message translates to:
  /// **'Parklar'**
  String get categoryParks;

  /// No description provided for @categoryRestaurants.
  ///
  /// In tr, this message translates to:
  /// **'Restoranlar'**
  String get categoryRestaurants;

  /// No description provided for @categoryCafes.
  ///
  /// In tr, this message translates to:
  /// **'Kafeler'**
  String get categoryCafes;

  /// No description provided for @categoryAttractions.
  ///
  /// In tr, this message translates to:
  /// **'Turistik Yerler'**
  String get categoryAttractions;

  /// No description provided for @categoryHistorical.
  ///
  /// In tr, this message translates to:
  /// **'Tarihi Yerler'**
  String get categoryHistorical;

  /// No description provided for @categoryShopping.
  ///
  /// In tr, this message translates to:
  /// **'Alışveriş'**
  String get categoryShopping;

  /// No description provided for @categoryHotels.
  ///
  /// In tr, this message translates to:
  /// **'Oteller'**
  String get categoryHotels;

  /// No description provided for @categoryChurches.
  ///
  /// In tr, this message translates to:
  /// **'Kiliseler'**
  String get categoryChurches;

  /// No description provided for @moodRomantic.
  ///
  /// In tr, this message translates to:
  /// **'Romantik'**
  String get moodRomantic;

  /// No description provided for @moodHistorical.
  ///
  /// In tr, this message translates to:
  /// **'Tarihi'**
  String get moodHistorical;

  /// No description provided for @moodRelaxing.
  ///
  /// In tr, this message translates to:
  /// **'Rahatlatıcı'**
  String get moodRelaxing;

  /// No description provided for @moodFamily.
  ///
  /// In tr, this message translates to:
  /// **'Aile'**
  String get moodFamily;

  /// No description provided for @moodScenic.
  ///
  /// In tr, this message translates to:
  /// **'Manzaralı'**
  String get moodScenic;

  /// No description provided for @moodFoodie.
  ///
  /// In tr, this message translates to:
  /// **'Gurme'**
  String get moodFoodie;

  /// No description provided for @moodPhotography.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf'**
  String get moodPhotography;

  /// No description provided for @moodNature.
  ///
  /// In tr, this message translates to:
  /// **'Doğa'**
  String get moodNature;

  /// No description provided for @moodAdventure.
  ///
  /// In tr, this message translates to:
  /// **'Macera'**
  String get moodAdventure;

  /// No description provided for @moodCultural.
  ///
  /// In tr, this message translates to:
  /// **'Kültürel'**
  String get moodCultural;

  /// No description provided for @moodSpiritual.
  ///
  /// In tr, this message translates to:
  /// **'Manevi'**
  String get moodSpiritual;

  /// No description provided for @moodLocal.
  ///
  /// In tr, this message translates to:
  /// **'Yerel'**
  String get moodLocal;

  /// No description provided for @moodHiddenGem.
  ///
  /// In tr, this message translates to:
  /// **'Gizli Hazine'**
  String get moodHiddenGem;

  /// No description provided for @moodSunset.
  ///
  /// In tr, this message translates to:
  /// **'Gün Batımı'**
  String get moodSunset;

  /// No description provided for @moodMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah'**
  String get moodMorning;

  /// No description provided for @moodNightlife.
  ///
  /// In tr, this message translates to:
  /// **'Gece Hayatı'**
  String get moodNightlife;

  /// No description provided for @timePeriodMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah'**
  String get timePeriodMorning;

  /// No description provided for @timePeriodAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'Öğleden Sonra'**
  String get timePeriodAfternoon;

  /// No description provided for @timePeriodEvening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get timePeriodEvening;

  /// No description provided for @timePeriodAnytime.
  ///
  /// In tr, this message translates to:
  /// **'Her Zaman'**
  String get timePeriodAnytime;

  /// No description provided for @timePeriodMorningDesc.
  ///
  /// In tr, this message translates to:
  /// **'06:00 - 12:00'**
  String get timePeriodMorningDesc;

  /// No description provided for @timePeriodAfternoonDesc.
  ///
  /// In tr, this message translates to:
  /// **'12:00 - 18:00'**
  String get timePeriodAfternoonDesc;

  /// No description provided for @timePeriodEveningDesc.
  ///
  /// In tr, this message translates to:
  /// **'18:00 - 00:00'**
  String get timePeriodEveningDesc;

  /// No description provided for @timePeriodAnytimeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Esnek zamanlama'**
  String get timePeriodAnytimeDesc;

  /// No description provided for @defaultCategoriesHint.
  ///
  /// In tr, this message translates to:
  /// **'Müzeler, Kafeler'**
  String get defaultCategoriesHint;

  /// No description provided for @defaultMoodsHint.
  ///
  /// In tr, this message translates to:
  /// **'Tarihi, Aile Dostu'**
  String get defaultMoodsHint;

  /// No description provided for @defaultDurationHint.
  ///
  /// In tr, this message translates to:
  /// **'Sabah, Her Zaman'**
  String get defaultDurationHint;

  /// No description provided for @defaultTransportHint.
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüş'**
  String get defaultTransportHint;

  /// No description provided for @selectedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} seçildi'**
  String selectedCount(int count);

  /// No description provided for @routeLoadingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geziniz Hazırlanıyor'**
  String get routeLoadingTitle;

  /// No description provided for @routeLoadingStep.
  ///
  /// In tr, this message translates to:
  /// **'Adım {step}'**
  String routeLoadingStep(int step);

  /// No description provided for @routeLoadingStatus.
  ///
  /// In tr, this message translates to:
  /// **'YÜKLENIYOR...'**
  String get routeLoadingStatus;

  /// No description provided for @routeLoadingPlacesConsidering.
  ///
  /// In tr, this message translates to:
  /// **'İncelediğimiz yerler'**
  String get routeLoadingPlacesConsidering;

  /// No description provided for @routeLoadingStep1Message.
  ///
  /// In tr, this message translates to:
  /// **'Gizli cevherleri keşfediyor... 💎'**
  String get routeLoadingStep1Message;

  /// No description provided for @routeLoadingStep2Message.
  ///
  /// In tr, this message translates to:
  /// **'Rotanızı optimize ediyor... 🗺️'**
  String get routeLoadingStep2Message;

  /// No description provided for @routeLoadingStep3Message.
  ///
  /// In tr, this message translates to:
  /// **'Yerel öneriler ekleniyor... ✨'**
  String get routeLoadingStep3Message;

  /// No description provided for @routeLoadingStep1Label.
  ///
  /// In tr, this message translates to:
  /// **'Tercihlerinize göre harika yerler bulunuyor'**
  String get routeLoadingStep1Label;

  /// No description provided for @routeLoadingStep2Label.
  ///
  /// In tr, this message translates to:
  /// **'En iyi deneyim için rotanız optimize ediliyor'**
  String get routeLoadingStep2Label;

  /// No description provided for @routeLoadingStep3Label.
  ///
  /// In tr, this message translates to:
  /// **'Yerel bilgiler ve öneriler ekleniyor'**
  String get routeLoadingStep3Label;

  /// No description provided for @searchBarPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Nereyi keşfetmek istersin?'**
  String get searchBarPlaceholder;

  /// No description provided for @routeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Rota kaydedildi'**
  String get routeSaved;

  /// No description provided for @routeUnsaved.
  ///
  /// In tr, this message translates to:
  /// **'Rota kaydedilenlerden kaldırıldı'**
  String get routeUnsaved;

  /// No description provided for @cannotSaveRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rota kaydedilemiyor'**
  String get cannotSaveRoute;

  /// No description provided for @failedToSaveRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rota kaydedilemedi'**
  String get failedToSaveRoute;

  /// No description provided for @noRouteYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz Rota Yok'**
  String get noRouteYet;

  /// No description provided for @createFirstRoute.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul\'u keşfetmeye başla ve ilk kişisel rotanı oluştur!'**
  String get createFirstRoute;

  /// No description provided for @createYourRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rotanı Oluştur'**
  String get createYourRoute;

  /// No description provided for @saved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get saved;

  /// No description provided for @startRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rotayı Başlat'**
  String get startRoute;

  /// No description provided for @stopsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Durak'**
  String stopsCount(int count);

  /// No description provided for @filterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get filterAll;

  /// No description provided for @filterWalking.
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüş'**
  String get filterWalking;

  /// No description provided for @filterTransit.
  ///
  /// In tr, this message translates to:
  /// **'Toplu Taşıma'**
  String get filterTransit;

  /// No description provided for @filterDriving.
  ///
  /// In tr, this message translates to:
  /// **'Araba'**
  String get filterDriving;

  /// No description provided for @transportDrive.
  ///
  /// In tr, this message translates to:
  /// **'Araba'**
  String get transportDrive;

  /// No description provided for @transportTransit.
  ///
  /// In tr, this message translates to:
  /// **'Toplu Taşıma'**
  String get transportTransit;

  /// No description provided for @transportWalk.
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüş'**
  String get transportWalk;

  /// No description provided for @placesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Yer'**
  String placesCount(int count);

  /// No description provided for @viewRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rotayı Gör'**
  String get viewRoute;

  /// No description provided for @preparingRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rota hazırlanıyor...'**
  String get preparingRoute;

  /// No description provided for @exploreRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rotayı Keşfet'**
  String get exploreRoute;

  /// No description provided for @categorySeaside.
  ///
  /// In tr, this message translates to:
  /// **'Sahil'**
  String get categorySeaside;

  /// No description provided for @categoryMosque.
  ///
  /// In tr, this message translates to:
  /// **'Cami'**
  String get categoryMosque;

  /// No description provided for @categoryScenic.
  ///
  /// In tr, this message translates to:
  /// **'Manzaralı'**
  String get categoryScenic;

  /// No description provided for @categoryLocal.
  ///
  /// In tr, this message translates to:
  /// **'Yerel'**
  String get categoryLocal;

  /// No description provided for @categoryCafe.
  ///
  /// In tr, this message translates to:
  /// **'Kafe'**
  String get categoryCafe;

  /// No description provided for @categoryRestaurant.
  ///
  /// In tr, this message translates to:
  /// **'Restoran'**
  String get categoryRestaurant;

  /// No description provided for @categoryPark.
  ///
  /// In tr, this message translates to:
  /// **'Park'**
  String get categoryPark;

  /// No description provided for @categoryMuseum.
  ///
  /// In tr, this message translates to:
  /// **'Müze'**
  String get categoryMuseum;

  /// No description provided for @categoryAttraction.
  ///
  /// In tr, this message translates to:
  /// **'Turistik Yer'**
  String get categoryAttraction;

  /// No description provided for @exploreCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get exploreCategories;

  /// No description provided for @exploreMood.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali'**
  String get exploreMood;

  /// No description provided for @exploreDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get exploreDuration;

  /// No description provided for @exploreTransport.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşım'**
  String get exploreTransport;

  /// No description provided for @createMyRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rotamı Oluştur'**
  String get createMyRoute;

  /// No description provided for @selectCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Seç'**
  String get selectCategories;

  /// No description provided for @choosePlacesToExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfetmek istediğin yerleri seç'**
  String get choosePlacesToExplore;

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// No description provided for @categorySelectedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{kategori seçildi} other{kategori seçildi}}'**
  String categorySelectedCount(int count);

  /// No description provided for @applySelection.
  ///
  /// In tr, this message translates to:
  /// **'Seçimi Uygula'**
  String get applySelection;

  /// No description provided for @moodTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugün ruh halin nasıl?'**
  String get moodTitle;

  /// No description provided for @moodSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul\'u sana özel hazırlayacağız.'**
  String get moodSubtitle;

  /// No description provided for @moodSelectedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{ruh hali seçildi} other{ruh hali seçildi}}'**
  String moodSelectedCount(int count);

  /// No description provided for @applyMood.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Halini Uygula'**
  String get applyMood;

  /// No description provided for @skipForNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik geç'**
  String get skipForNow;

  /// No description provided for @durationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get durationTitle;

  /// No description provided for @hourSingular.
  ///
  /// In tr, this message translates to:
  /// **'saat'**
  String get hourSingular;

  /// No description provided for @hourPlural.
  ///
  /// In tr, this message translates to:
  /// **'saat'**
  String get hourPlural;

  /// No description provided for @hourAbbr.
  ///
  /// In tr, this message translates to:
  /// **'sa'**
  String get hourAbbr;

  /// No description provided for @applyDuration.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get applyDuration;

  /// No description provided for @transportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl\ngezmek istersin?'**
  String get transportTitle;

  /// No description provided for @transportSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul\'u keşfetmek için tercih ettiğin ulaşım yolunu seç.'**
  String get transportSubtitle;

  /// No description provided for @applyTransport.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşımı Uygula'**
  String get applyTransport;

  /// No description provided for @curatedRoutes.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen Rotalar'**
  String get curatedRoutes;

  /// No description provided for @curatedRoutesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yerliler tarafından özenle seçilmiş deneyimler'**
  String get curatedRoutesSubtitle;

  /// No description provided for @somethingWentWrong.
  ///
  /// In tr, this message translates to:
  /// **'Hay aksi! Bir şeyler ters gitti'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgain;

  /// No description provided for @noRoutesFound.
  ///
  /// In tr, this message translates to:
  /// **'Rota bulunamadı'**
  String get noRoutesFound;

  /// No description provided for @noRoutesFoundSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla rota keşfetmek için\nfarklı bir filtre seçmeyi dene'**
  String get noRoutesFoundSubtitle;

  /// No description provided for @showAllRoutes.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Rotaları Göster'**
  String get showAllRoutes;

  /// No description provided for @routeReady.
  ///
  /// In tr, this message translates to:
  /// **'Rotan Hazır!'**
  String get routeReady;

  /// No description provided for @routeReadySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tercihlerine göre mükemmel bir gezi planı hazırladık'**
  String get routeReadySubtitle;

  /// No description provided for @placesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yer'**
  String get placesLabel;

  /// No description provided for @durationLabel.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get durationLabel;

  /// No description provided for @kmLabel.
  ///
  /// In tr, this message translates to:
  /// **'km'**
  String get kmLabel;

  /// No description provided for @viewMyRoute.
  ///
  /// In tr, this message translates to:
  /// **'Rotamı Gör'**
  String get viewMyRoute;

  /// No description provided for @tripPlanner.
  ///
  /// In tr, this message translates to:
  /// **'GEZİ PLANLAYICI'**
  String get tripPlanner;

  /// No description provided for @suggestedItineraries.
  ///
  /// In tr, this message translates to:
  /// **'ÖNERİLEN GÜZERGAHLAR'**
  String get suggestedItineraries;

  /// No description provided for @aiCraftingRoute.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka rotanı oluşturuyor...'**
  String get aiCraftingRoute;

  /// No description provided for @findingBestSpots.
  ///
  /// In tr, this message translates to:
  /// **'En iyi noktalar bulunuyor...'**
  String get findingBestSpots;

  /// No description provided for @personalizingJourney.
  ///
  /// In tr, this message translates to:
  /// **'Gezin kişiselleştiriliyor...'**
  String get personalizingJourney;

  /// No description provided for @enrichingDetails.
  ///
  /// In tr, this message translates to:
  /// **'Mekan detayları zenginleştiriliyor...'**
  String get enrichingDetails;

  /// No description provided for @fetchingPhotos.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar ve puanlar yükleniyor...'**
  String get fetchingPhotos;

  /// No description provided for @finalizingItinerary.
  ///
  /// In tr, this message translates to:
  /// **'Gezi planın son şeklini alıyor...'**
  String get finalizingItinerary;

  /// No description provided for @analyzingPreferences.
  ///
  /// In tr, this message translates to:
  /// **'Tercihleriniz analiz ediliyor'**
  String get analyzingPreferences;

  /// No description provided for @selectingLocations.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel mekanlar seçiliyor'**
  String get selectingLocations;

  /// No description provided for @creatingSequence.
  ///
  /// In tr, this message translates to:
  /// **'En uygun sıralama oluşturuluyor'**
  String get creatingSequence;

  /// No description provided for @gettingRealtimeData.
  ///
  /// In tr, this message translates to:
  /// **'Anlık veriler alınıyor'**
  String get gettingRealtimeData;

  /// No description provided for @loadingPlaceInfo.
  ///
  /// In tr, this message translates to:
  /// **'Mekan bilgileri yükleniyor'**
  String get loadingPlaceInfo;

  /// No description provided for @almostReady.
  ///
  /// In tr, this message translates to:
  /// **'Neredeyse hazır!'**
  String get almostReady;

  /// No description provided for @openNow.
  ///
  /// In tr, this message translates to:
  /// **'AÇIK'**
  String get openNow;

  /// No description provided for @aboutSection.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get aboutSection;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama bulunmuyor.'**
  String get noDescriptionAvailable;

  /// No description provided for @unableToLoadPlaceDetails.
  ///
  /// In tr, this message translates to:
  /// **'Mekan detayları yüklenemedi'**
  String get unableToLoadPlaceDetails;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get termsOfServiceTitle;

  /// No description provided for @termsReadCarefully.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen dikkatlice okuyun'**
  String get termsReadCarefully;

  /// No description provided for @termsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları yüklenemedi. Lütfen daha sonra tekrar deneyin.'**
  String get termsLoadFailed;

  /// No description provided for @snackbarPasswordRequirements.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm şifre gereksinimlerini karşılayın'**
  String get snackbarPasswordRequirements;

  /// No description provided for @snackbarPasswordResetSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Şifre başarıyla sıfırlandı!'**
  String get snackbarPasswordResetSuccess;

  /// No description provided for @snackbarAtLeastTwoStops.
  ///
  /// In tr, this message translates to:
  /// **'Navigasyonu başlatmak için en az 2 durak gereklidir'**
  String get snackbarAtLeastTwoStops;

  /// No description provided for @snackbarCouldNotOpenMaps.
  ///
  /// In tr, this message translates to:
  /// **'Google Haritalar açılamadı'**
  String get snackbarCouldNotOpenMaps;

  /// No description provided for @snackbarFailedGenerateLink.
  ///
  /// In tr, this message translates to:
  /// **'Rota bağlantısı oluşturulamadı'**
  String get snackbarFailedGenerateLink;

  /// No description provided for @snackbarRouteTakingLonger.
  ///
  /// In tr, this message translates to:
  /// **'Rota oluşturma beklenenden uzun sürüyor...'**
  String get snackbarRouteTakingLonger;

  /// No description provided for @snackbarErrorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get snackbarErrorOccurred;

  /// No description provided for @snackbarFailedLoadRouteDetails.
  ///
  /// In tr, this message translates to:
  /// **'Rota detayları yüklenemedi'**
  String get snackbarFailedLoadRouteDetails;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
