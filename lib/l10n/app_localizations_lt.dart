import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appTitle => 'PokerStreet';

  @override
  String get events => 'Įvykiai';

  @override
  String get topPlayers => 'Geriausi žaidėjai';

  @override
  String get profile => 'Profilis';

  @override
  String get settings => 'Nustatymai';

  @override
  String get language => 'Kalba';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Šviesi';

  @override
  String get dark => 'Tamsi';

  @override
  String get system => 'Sistemos';

  @override
  String get english => 'Anglų';

  @override
  String get lithuanian => 'Lietuvių';

  @override
  String get eventsPageTitle => 'Įvykiai';

  @override
  String get topPlayersPageTitle => 'Geriausi žaidėjai';

  @override
  String get profilePageTitle => 'Profilis';

  @override
  String get noEventsAvailable => 'Nėra prieinamy įvykių';

  @override
  String get noPlayersAvailable => 'Nėra prieinamų žaidėjų';

  @override
  String get profileNotAvailable => 'Profilis neprieinamas';

  @override
  String get pleaseLoginToViewProfile => 'Prisijunkite, kad peržiūrėtumėte savo profilį';

  @override
  String get loginPromptDescription => 'Turite būti prisijungę, kad galėtumėte pasiekti savo profilio informaciją';

  @override
  String get login => 'Prisijungti';

  @override
  String get accountInformation => 'Paskyros informacija';

  @override
  String get userId => 'Vartotojo ID';

  @override
  String get name => 'Vardas';

  @override
  String get email => 'El. paštas';

  @override
  String get memberSince => 'Narys nuo';

  @override
  String get myEvents => 'Mano įvykiai';

  @override
  String get noEventsFound => 'Nerasta įvykių';

  @override
  String get noEventsDescription => 'Dar nedalyvavote jokiuose įvykiuose';

  @override
  String get errorLoadingProfile => 'Klaida kraunant profilį';

  @override
  String get pleaseRetryLater => 'Bandykite dar kartą vėliau';

  @override
  String get eventStatus => 'Būsena';

  @override
  String get position => 'Pozicija';

  @override
  String get score => 'Taškai';

  @override
  String get balance => 'Balansas';

  @override
  String get joinedAt => 'Prisijungė';

  @override
  String get completed => 'Baigtas';

  @override
  String get inProgress => 'Vyksta';

  @override
  String get paused => 'Pristabdytas';

  @override
  String get upcoming => 'Būsimas';

  @override
  String get active => 'Aktyvus';

  @override
  String get eliminated => 'Eliminuotas';

  @override
  String get loadingEvents => 'Kraunami renginiai...';

  @override
  String get loadingMoreEvents => 'Kraunami daugiau renginių...';

  @override
  String get loadingProfile => 'Kraunamas profilis...';

  @override
  String get pleaseWait => 'Palaukite, kol įkeliame jūsų informaciją';

  @override
  String get totalEvents => 'Visi renginiai';

  @override
  String viewAllEvents(int count) {
    return 'Peržiūrėti visus $count renginius';
  }

  @override
  String get sortByDate => 'Rūšiuoti pagal datą';

  @override
  String get sortByName => 'Rūšiuoti pagal pavadinimą';

  @override
  String get sortByPosition => 'Rūšiuoti pagal poziciją';

  @override
  String get allEvents => 'Visi renginiai';

  @override
  String get averagePosition => 'Vid. pozicija';

  @override
  String get totalBalance => 'Bendras balansas';

  @override
  String showingFilteredEvents(int filtered, int total) {
    return 'Rodoma $filtered iš $total renginių';
  }

  @override
  String get clearFilter => 'Išvalyti filtrą';

  @override
  String get joinedOn => 'Prisijungė';

  @override
  String get participationStatus => 'Dalyvavimo statusas';

  @override
  String get close => 'Uždaryti';
}
