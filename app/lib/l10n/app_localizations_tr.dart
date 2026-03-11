// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'GezAI';

  @override
  String get cancel => 'İptal';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get gotIt => 'Anladım';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get appTitle => 'GezAI';

  @override
  String get appDescription =>
      'İstanbul için yapay zeka destekli seyahat arkadaşı';

  @override
  String get authWelcomeBack => 'Hoş Geldin!';

  @override
  String get authPlanAdventure => 'Bir sonraki İstanbul maceranı planla.';

  @override
  String get authEmailAddress => 'E-posta Adresi';

  @override
  String get authPassword => 'Şifre';

  @override
  String get authForgotPassword => 'Şifremi Unuttum?';

  @override
  String get authSignIn => 'Giriş Yap';

  @override
  String get authOrContinueWith => 'Veya şununla devam et';

  @override
  String get authContinueWithGoogle => 'Google ile Devam Et';

  @override
  String get authNewToApp => 'Uygulamada yeni misin? ';

  @override
  String get authCreateAccount => 'Hesap Oluştur';

  @override
  String get authCreateYourAccount => 'Hesabını Oluştur';

  @override
  String get authStartPlanning => 'İstanbul maceranı planlamaya başla';

  @override
  String get authFullName => 'Ad Soyad';

  @override
  String get authConfirmPassword => 'Şifreyi Onayla';

  @override
  String get authPasswordStrengthWeak => 'Zayıf';

  @override
  String get authPasswordStrengthMedium => 'Orta';

  @override
  String get authPasswordStrengthGood => 'İyi';

  @override
  String get authPasswordStrengthStrong => 'Güçlü';

  @override
  String get authAgreeToTerms => 'Hizmet Şartları\'nı kabul ediyorum ';

  @override
  String get authTermsOfService => 'Hizmet Şartları';

  @override
  String get authSignInWithGoogle => 'Google ile Giriş Yap';

  @override
  String get authAlreadyHaveAccount => 'Zaten hesabın var mı? ';

  @override
  String get authPleaseAgreeToTerms => 'Lütfen Hizmet Şartları\'nı kabul edin';

  @override
  String get authForgotPasswordTitle => 'Şifreni Unuttun mu?';

  @override
  String get authResetInstructions =>
      'E-postanı gir, hesabınla ilişkiliyse sana şifre sıfırlama bağlantısı gönderelim.';

  @override
  String get authEnterYourEmail => 'E-postanı gir';

  @override
  String get authSendResetLink => 'Sıfırlama Bağlantısı Gönder';

  @override
  String get authBackToSignIn => 'Girişe Dön';

  @override
  String get authVerifyEmail => 'E-postanı Doğrula';

  @override
  String authVerificationSentTo(String email) {
    return '$email adresine doğrulama bağlantısı gönderdik';
  }

  @override
  String get authClickLinkToVerify =>
      'Hesabını doğrulamak için e-postadaki bağlantıya tıkla';

  @override
  String get authResendEmail => 'E-postayı Tekrar Gönder';

  @override
  String authResendInSeconds(int seconds) {
    return 'Tekrar gönder ${seconds}s';
  }

  @override
  String get authWrongEmailGoBack => 'Yanlış e-posta mı? Geri dön';

  @override
  String get authVerificationEmailSent => 'Doğrulama e-postası gönderildi!';

  @override
  String get authCheckYourEmail => 'E-postanı Kontrol Et';

  @override
  String get authResetLinkSent =>
      'E-postanla ilişkili bir hesap varsa, e-posta adresine şifre sıfırlama bağlantısı gönderdik.';

  @override
  String get authDidntReceiveEmail => 'E-postayı almadın mı? ';

  @override
  String get authResendLink => 'Bağlantıyı Tekrar Gönder';

  @override
  String get validationEmailRequired => 'Lütfen e-postanızı girin';

  @override
  String get validationEmailInvalid =>
      'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get validationPasswordRequired => 'Lütfen şifrenizi girin';

  @override
  String get validationPasswordTooShort => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get validationPasswordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get validationNameRequired => 'Lütfen adınızı girin';

  @override
  String get validationPasswordConfirmRequired => 'Lütfen şifrenizi onaylayın';

  @override
  String get errorUserNotFound =>
      'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';

  @override
  String get errorWrongPassword => 'Hatalı şifre.';

  @override
  String get errorInvalidEmail => 'Geçersiz e-posta adresi.';

  @override
  String get errorUserDisabled => 'Bu hesap devre dışı bırakılmış.';

  @override
  String get errorEmailAlreadyInUse => 'Bu e-posta adresi zaten kullanılıyor.';

  @override
  String get errorWeakPassword => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get errorOperationNotAllowed => 'Bu giriş yöntemi etkin değil.';

  @override
  String get errorTooManyRequests =>
      'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';

  @override
  String get errorNetworkRequestFailed =>
      'Ağ hatası. Lütfen bağlantınızı kontrol edin.';

  @override
  String get errorGoogleSignInCancelled => 'Google girişi iptal edildi';

  @override
  String get errorGoogleSignInFailed => 'Google girişi başarısız oldu';

  @override
  String get errorUnknown => 'Bilinmeyen bir hata oluştu';

  @override
  String get errorInvalidCredential => 'Girdiğiniz e-posta veya şifre hatalı.';

  @override
  String get errorExpiredActionCode =>
      'Bu bağlantının süresi dolmuş. Lütfen yeni bir tane talep edin.';

  @override
  String get errorInvalidActionCode =>
      'Bu bağlantı geçersiz. Lütfen yeni bir tane talep edin.';

  @override
  String get errorRequiresRecentLogin =>
      'Bu işlemi tamamlamak için lütfen tekrar giriş yapın.';

  @override
  String get errorAccountExistsWithDifferentCredential =>
      'Bu e-posta adresiyle farklı bir giriş yöntemi kullanılarak oluşturulmuş bir hesap zaten var.';

  @override
  String get errorCredentialAlreadyInUse =>
      'Bu kimlik bilgisi zaten başka bir hesapla ilişkilendirilmiş.';

  @override
  String get errorResetPasswordFailed =>
      'Şifre sıfırlanamadı. Lütfen tekrar deneyin.';

  @override
  String get welcomeTitle => 'İstanbul Rehberi';

  @override
  String get welcomeTagline => 'İstanbul\'u Kendi Tarzınla Keşfet';

  @override
  String get welcomeGetStarted => 'Başla';

  @override
  String get welcomeAlreadyHaveAccount => 'Zaten hesabım var';

  @override
  String get welcomeTopPick => 'En İyi Seçim';

  @override
  String get welcomeHistoricalPeninsula => 'Tarihi Yarımada';

  @override
  String welcomeRouteHours(int hours) {
    return '$hours saatlik rota';
  }

  @override
  String get navExplore => 'Keşfet';

  @override
  String get navRoutes => 'Rotalar';

  @override
  String get navAdvice => 'Öneri';

  @override
  String get navSaved => 'Kayıtlı';

  @override
  String get navProfile => 'Profil';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDefaultName => 'Gezgin';

  @override
  String get profileStatsRoutes => 'Rotalar';

  @override
  String get profileStatsSaved => 'Kaydedilenler';

  @override
  String get profileStatsExplored => 'Keşfedilenler';

  @override
  String get profileMenuEditProfile => 'Profili Düzenle';

  @override
  String get profileMenuNotifications => 'Bildirimler';

  @override
  String get profileMenuLanguage => 'Dil';

  @override
  String get profileMenuHelp => 'Yardım ve Destek';

  @override
  String get profileMenuAbout => 'GezAI Hakkında';

  @override
  String get profileLanguageValue => 'Türkçe';

  @override
  String get profileAboutVersion => 'Versiyon 1.0.0 (MVP)';

  @override
  String get profileAboutDescription =>
      'İstanbul\'u keşfetmek için\nyapay zeka destekli seyahat arkadaşı';

  @override
  String get profileLogoutTitle => 'Çıkış Yap?';

  @override
  String get profileLogoutMessage =>
      'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get profileLogoutButton => 'Çıkış Yap';

  @override
  String get profileLogoutCancel => 'İptal';

  @override
  String get profileLogoutConfirm => 'Çıkış Yap';

  @override
  String get profileMenuLanguageTrailing => 'Türkçe';

  @override
  String get profileAboutButton => 'Anladım';

  @override
  String profileComingSoon(String feature) {
    return '$feature yakında geliyor!';
  }

  @override
  String get myRoutesTitle => 'Rotalarım';

  @override
  String get myRoutesSavedBadge => 'Kaydedilenler';

  @override
  String get myRoutesSubtitle => 'Kaldığın yerden devam et';

  @override
  String get myRoutesEmptyTitle => 'Henüz kaydedilmiş rota yok';

  @override
  String get myRoutesEmptySubtitle =>
      'İstanbul\'u keşfetmeye başla ve\ndaha sonra denemek istediğin rotaları kaydet!';

  @override
  String get myRoutesEmptyDescription =>
      'İstanbul\'u keşfetmeye başla ve\ndaha sonra denemek istediğin rotaları kaydet!';

  @override
  String get myRoutesDiscoverButton => 'Rotaları Keşfet';

  @override
  String get myRoutesErrorTitle => 'Rotalar yüklenemedi';

  @override
  String get myRoutesLoadingError => 'Rotalar yüklenemedi';

  @override
  String get myRoutesRetryButton => 'Tekrar Dene';

  @override
  String get myRoutesRetry => 'Tekrar Dene';

  @override
  String get myRoutesDeleteDialogTitle => 'Rotayı Sil?';

  @override
  String get myRoutesDeleteTitle => 'Rotayı Sil?';

  @override
  String myRoutesDeleteDialogMessage(String title) {
    return '\"$title\" rotasını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String myRoutesDeleteMessage(String title) {
    return '\"$title\" rotasını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get myRoutesCancelButton => 'İptal';

  @override
  String get myRoutesDeleteButton => 'Sil';

  @override
  String get myRoutesDeleteSuccess => 'Rota başarıyla silindi';

  @override
  String myRoutesDeleteFailed(String error) {
    return 'Rota silinemedi: $error';
  }

  @override
  String myRoutesDeleteError(String error) {
    return 'Rota silinemedi: $error';
  }

  @override
  String myRoutesLoadFailed(String error) {
    return 'Rota yüklenemedi: $error';
  }

  @override
  String myRoutesLoadError(String error) {
    return 'Rota yüklenemedi: $error';
  }

  @override
  String get transportWalkingName => 'Yürüyüş';

  @override
  String get transportWalkingDescription => 'Tarihi sokakları yürüyerek keşfet';

  @override
  String get transportWalkingBestFor => 'Gezinti için en uygun';

  @override
  String get transportPublicTransitName => 'Toplu Taşıma';

  @override
  String get transportPublicTransitDescription =>
      'Metro, otobüs ve tramvayla şehri dolaş';

  @override
  String get transportPublicTransitBestFor => 'Uzun mesafeler için en uygun';

  @override
  String get transportDrivingName => 'Araba';

  @override
  String get transportDrivingDescription => 'İstanbul\'u arabayla gezin';

  @override
  String get transportDrivingBestFor => 'Esneklik için en uygun';

  @override
  String get categoryMosques => 'Camiler';

  @override
  String get categoryMuseums => 'Müzeler';

  @override
  String get categoryParks => 'Parklar';

  @override
  String get categoryRestaurants => 'Restoranlar';

  @override
  String get categoryCafes => 'Kafeler';

  @override
  String get categoryAttractions => 'Turistik Yerler';

  @override
  String get categoryHistorical => 'Tarihi Yerler';

  @override
  String get categoryShopping => 'Alışveriş';

  @override
  String get categoryHotels => 'Oteller';

  @override
  String get categoryChurches => 'Kiliseler';

  @override
  String get moodRomantic => 'Romantik';

  @override
  String get moodHistorical => 'Tarihi';

  @override
  String get moodRelaxing => 'Rahatlatıcı';

  @override
  String get moodFamily => 'Aile';

  @override
  String get moodScenic => 'Manzaralı';

  @override
  String get moodFoodie => 'Gurme';

  @override
  String get moodPhotography => 'Fotoğraf';

  @override
  String get moodNature => 'Doğa';

  @override
  String get moodAdventure => 'Macera';

  @override
  String get moodCultural => 'Kültürel';

  @override
  String get moodSpiritual => 'Manevi';

  @override
  String get moodLocal => 'Yerel';

  @override
  String get moodHiddenGem => 'Gizli Hazine';

  @override
  String get moodSunset => 'Gün Batımı';

  @override
  String get moodMorning => 'Sabah';

  @override
  String get moodNightlife => 'Gece Hayatı';

  @override
  String get timePeriodMorning => 'Sabah';

  @override
  String get timePeriodAfternoon => 'Öğleden Sonra';

  @override
  String get timePeriodEvening => 'Akşam';

  @override
  String get timePeriodAnytime => 'Her Zaman';

  @override
  String get timePeriodMorningDesc => '06:00 - 12:00';

  @override
  String get timePeriodAfternoonDesc => '12:00 - 18:00';

  @override
  String get timePeriodEveningDesc => '18:00 - 00:00';

  @override
  String get timePeriodAnytimeDesc => 'Esnek zamanlama';

  @override
  String get defaultCategoriesHint => 'Müzeler, Kafeler';

  @override
  String get defaultMoodsHint => 'Tarihi, Aile Dostu';

  @override
  String get defaultDurationHint => 'Sabah, Her Zaman';

  @override
  String get defaultTransportHint => 'Yürüyüş';

  @override
  String selectedCount(int count) {
    return '$count seçildi';
  }

  @override
  String get routeLoadingTitle => 'Geziniz Hazırlanıyor';

  @override
  String routeLoadingStep(int step) {
    return 'Adım $step';
  }

  @override
  String get routeLoadingStatus => 'YÜKLENIYOR...';

  @override
  String get routeLoadingPlacesConsidering => 'İncelediğimiz yerler';

  @override
  String get routeLoadingStep1Message => 'Gizli cevherleri keşfediyor... 💎';

  @override
  String get routeLoadingStep2Message => 'Rotanızı optimize ediyor... 🗺️';

  @override
  String get routeLoadingStep3Message => 'Yerel öneriler ekleniyor... ✨';

  @override
  String get routeLoadingStep1Label =>
      'Tercihlerinize göre harika yerler bulunuyor';

  @override
  String get routeLoadingStep2Label =>
      'En iyi deneyim için rotanız optimize ediliyor';

  @override
  String get routeLoadingStep3Label => 'Yerel bilgiler ve öneriler ekleniyor';

  @override
  String get searchBarPlaceholder => 'Nereyi keşfetmek istersin?';

  @override
  String get routeSaved => 'Rota kaydedildi';

  @override
  String get routeUnsaved => 'Rota kaydedilenlerden kaldırıldı';

  @override
  String get cannotSaveRoute => 'Rota kaydedilemiyor';

  @override
  String get failedToSaveRoute => 'Rota kaydedilemedi';

  @override
  String get noRouteYet => 'Henüz Rota Yok';

  @override
  String get createFirstRoute =>
      'İstanbul\'u keşfetmeye başla ve ilk kişisel rotanı oluştur!';

  @override
  String get createYourRoute => 'Rotanı Oluştur';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get startRoute => 'Rotayı Başlat';

  @override
  String stopsCount(int count) {
    return '$count Durak';
  }

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterWalking => 'Yürüyüş';

  @override
  String get filterTransit => 'Toplu Taşıma';

  @override
  String get filterDriving => 'Araba';

  @override
  String get transportDrive => 'Araba';

  @override
  String get transportTransit => 'Toplu Taşıma';

  @override
  String get transportWalk => 'Yürüyüş';

  @override
  String placesCount(int count) {
    return '$count Yer';
  }

  @override
  String get viewRoute => 'Rotayı Gör';

  @override
  String get preparingRoute => 'Rota hazırlanıyor...';

  @override
  String get exploreRoute => 'Rotayı Keşfet';

  @override
  String get categorySeaside => 'Sahil';

  @override
  String get categoryMosque => 'Cami';

  @override
  String get categoryScenic => 'Manzaralı';

  @override
  String get categoryLocal => 'Yerel';

  @override
  String get categoryCafe => 'Kafe';

  @override
  String get categoryRestaurant => 'Restoran';

  @override
  String get categoryPark => 'Park';

  @override
  String get categoryMuseum => 'Müze';

  @override
  String get categoryAttraction => 'Turistik Yer';

  @override
  String get exploreCategories => 'Kategoriler';

  @override
  String get exploreMood => 'Ruh Hali';

  @override
  String get exploreDuration => 'Süre';

  @override
  String get exploreTransport => 'Ulaşım';

  @override
  String get createMyRoute => 'Rotamı Oluştur';

  @override
  String get selectCategories => 'Kategori Seç';

  @override
  String get choosePlacesToExplore => 'Keşfetmek istediğin yerleri seç';

  @override
  String get clear => 'Temizle';

  @override
  String categorySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kategori seçildi',
      one: 'kategori seçildi',
    );
    return '$_temp0';
  }

  @override
  String get applySelection => 'Seçimi Uygula';

  @override
  String get moodTitle => 'Bugün ruh halin nasıl?';

  @override
  String get moodSubtitle => 'İstanbul\'u sana özel hazırlayacağız.';

  @override
  String moodSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ruh hali seçildi',
      one: 'ruh hali seçildi',
    );
    return '$_temp0';
  }

  @override
  String get applyMood => 'Ruh Halini Uygula';

  @override
  String get skipForNow => 'Şimdilik geç';

  @override
  String get durationTitle => 'Süre';

  @override
  String get hourSingular => 'saat';

  @override
  String get hourPlural => 'saat';

  @override
  String get hourAbbr => 'sa';

  @override
  String get applyDuration => 'Uygula';

  @override
  String get transportTitle => 'Nasıl\ngezmek istersin?';

  @override
  String get transportSubtitle =>
      'İstanbul\'u keşfetmek için tercih ettiğin ulaşım yolunu seç.';

  @override
  String get applyTransport => 'Ulaşımı Uygula';

  @override
  String get curatedRoutes => 'Önerilen Rotalar';

  @override
  String get curatedRoutesSubtitle =>
      'Yerliler tarafından özenle seçilmiş deneyimler';

  @override
  String get somethingWentWrong => 'Hay aksi! Bir şeyler ters gitti';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get noRoutesFound => 'Rota bulunamadı';

  @override
  String get noRoutesFoundSubtitle =>
      'Daha fazla rota keşfetmek için\nfarklı bir filtre seçmeyi dene';

  @override
  String get showAllRoutes => 'Tüm Rotaları Göster';

  @override
  String get routeReady => 'Rotan Hazır!';

  @override
  String get routeReadySubtitle =>
      'Tercihlerine göre mükemmel bir gezi planı hazırladık';

  @override
  String get placesLabel => 'Yer';

  @override
  String get durationLabel => 'Süre';

  @override
  String get kmLabel => 'km';

  @override
  String get viewMyRoute => 'Rotamı Gör';

  @override
  String get tripPlanner => 'GEZİ PLANLAYICI';

  @override
  String get suggestedItineraries => 'ÖNERİLEN GÜZERGAHLAR';

  @override
  String get aiCraftingRoute => 'Yapay zeka rotanı oluşturuyor...';

  @override
  String get findingBestSpots => 'En iyi noktalar bulunuyor...';

  @override
  String get personalizingJourney => 'Gezin kişiselleştiriliyor...';

  @override
  String get enrichingDetails => 'Mekan detayları zenginleştiriliyor...';

  @override
  String get fetchingPhotos => 'Fotoğraflar ve puanlar yükleniyor...';

  @override
  String get finalizingItinerary => 'Gezi planın son şeklini alıyor...';

  @override
  String get analyzingPreferences => 'Tercihleriniz analiz ediliyor';

  @override
  String get selectingLocations => 'Mükemmel mekanlar seçiliyor';

  @override
  String get creatingSequence => 'En uygun sıralama oluşturuluyor';

  @override
  String get gettingRealtimeData => 'Anlık veriler alınıyor';

  @override
  String get loadingPlaceInfo => 'Mekan bilgileri yükleniyor';

  @override
  String get almostReady => 'Neredeyse hazır!';

  @override
  String get openNow => 'AÇIK';

  @override
  String get aboutSection => 'Hakkında';

  @override
  String get noDescriptionAvailable => 'Açıklama bulunmuyor.';

  @override
  String get unableToLoadPlaceDetails => 'Mekan detayları yüklenemedi';

  @override
  String get termsOfServiceTitle => 'Kullanım Koşulları';

  @override
  String get termsReadCarefully => 'Lütfen dikkatlice okuyun';

  @override
  String get termsLoadFailed =>
      'Kullanım Koşulları yüklenemedi. Lütfen daha sonra tekrar deneyin.';

  @override
  String get snackbarPasswordRequirements =>
      'Lütfen tüm şifre gereksinimlerini karşılayın';

  @override
  String get snackbarPasswordResetSuccess => 'Şifre başarıyla sıfırlandı!';

  @override
  String get snackbarAtLeastTwoStops =>
      'Navigasyonu başlatmak için en az 2 durak gereklidir';

  @override
  String get snackbarCouldNotOpenMaps => 'Google Haritalar açılamadı';

  @override
  String get snackbarFailedGenerateLink => 'Rota bağlantısı oluşturulamadı';

  @override
  String get snackbarRouteTakingLonger =>
      'Rota oluşturma beklenenden uzun sürüyor...';

  @override
  String get snackbarErrorOccurred => 'Bir hata oluştu';

  @override
  String get snackbarFailedLoadRouteDetails => 'Rota detayları yüklenemedi';
}
