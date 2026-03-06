import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr'),
  ];

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @user.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get user;

  /// No description provided for @errorPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String errorPrefix(String error);

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUp;

  /// No description provided for @switchToSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get switchToSignIn;

  /// No description provided for @switchToSignUp.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? S\'inscrire'**
  String get switchToSignUp;

  /// No description provided for @orDivider.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get orDivider;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @errorGoogleCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Google annulée.'**
  String get errorGoogleCancelled;

  /// No description provided for @errorGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Erreur Google Sign-In. Veuillez réessayer.'**
  String get errorGoogle;

  /// No description provided for @errorEmptyFields.
  ///
  /// In fr, this message translates to:
  /// **'Merci de remplir tous les champs.'**
  String get errorEmptyFields;

  /// No description provided for @errorEmptyFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Merci d\'entrer votre prénom.'**
  String get errorEmptyFirstName;

  /// No description provided for @errorInvalidCredential.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect.'**
  String get errorInvalidCredential;

  /// No description provided for @errorEmailInUse.
  ///
  /// In fr, this message translates to:
  /// **'Cet email est déjà utilisé.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible (min. 6 caractères).'**
  String get errorWeakPassword;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide.'**
  String get errorInvalidEmail;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get errorUnknown;

  /// No description provided for @myGroupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon groupe'**
  String get myGroupTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue !'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez un groupe ou rejoignez-en un existant.'**
  String get welcomeSubtitle;

  /// No description provided for @createGroupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un groupe'**
  String get createGroupTitle;

  /// No description provided for @groupNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du groupe'**
  String get groupNameLabel;

  /// No description provided for @groupNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Famille Dupont'**
  String get groupNameHint;

  /// No description provided for @createButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get createButton;

  /// No description provided for @joinGroupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre un groupe'**
  String get joinGroupTitle;

  /// No description provided for @groupCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 caractères'**
  String get groupCodeLabel;

  /// No description provided for @groupCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : ABC123'**
  String get groupCodeHint;

  /// No description provided for @joinButton.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get joinButton;

  /// No description provided for @errorInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide. Vérifiez et réessayez.'**
  String get errorInvalidCode;

  /// No description provided for @errorGroupCreation.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création : {error}'**
  String errorGroupCreation(String error);

  /// No description provided for @errorGroupJoin.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la jonction : {error}'**
  String errorGroupJoin(String error);

  /// No description provided for @createGroupButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer le groupe'**
  String get createGroupButton;

  /// No description provided for @errorEmptyGroupName.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un nom de groupe.'**
  String get errorEmptyGroupName;

  /// No description provided for @errorEmptyCode.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un code de groupe.'**
  String get errorEmptyCode;

  /// No description provided for @settingsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres groupes'**
  String get settingsTooltip;

  /// No description provided for @inviteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get inviteTooltip;

  /// No description provided for @logoutTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logoutTooltip;

  /// No description provided for @inviteDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inviter quelqu\'un'**
  String get inviteDialogTitle;

  /// No description provided for @inviteDialogSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Partage ce code pour rejoindre le groupe :'**
  String get inviteDialogSubtitle;

  /// No description provided for @copyButton.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copyButton;

  /// No description provided for @codeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code copié !'**
  String get codeCopied;

  /// No description provided for @totalExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Total des dépenses (en €)'**
  String get totalExpenses;

  /// No description provided for @noExpensesForPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense pour cette période'**
  String get noExpensesForPeriod;

  /// No description provided for @viewDetails.
  ///
  /// In fr, this message translates to:
  /// **'Voir le détail'**
  String get viewDetails;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toujours'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In fr, this message translates to:
  /// **'Ce jour'**
  String get filterToday;

  /// No description provided for @filterThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get filterThisWeek;

  /// No description provided for @filterThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get filterThisMonth;

  /// No description provided for @filterThisYear.
  ///
  /// In fr, this message translates to:
  /// **'Cette année'**
  String get filterThisYear;

  /// No description provided for @filterAllMembers.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAllMembers;

  /// No description provided for @filterAllCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get filterAllCategories;

  /// No description provided for @deleteBeneficiaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le bénéficiaire'**
  String get deleteBeneficiaryTitle;

  /// No description provided for @deleteBeneficiaryConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer \"{name}\" de la liste ?'**
  String deleteBeneficiaryConfirm(String name);

  /// No description provided for @statisticsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statisticsTitle;

  /// No description provided for @categoryBreakdown.
  ///
  /// In fr, this message translates to:
  /// **'Répartition par catégorie'**
  String get categoryBreakdown;

  /// No description provided for @expenseCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{# dépense} other{# dépenses}}'**
  String expenseCount(int count);

  /// No description provided for @totalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @whichCategory.
  ///
  /// In fr, this message translates to:
  /// **'Quelle catégorie ?'**
  String get whichCategory;

  /// No description provided for @addCategoryTile.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addCategoryTile;

  /// No description provided for @newCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get newCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get categoryNameLabel;

  /// No description provided for @chooseIcon.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une icône :'**
  String get chooseIcon;

  /// No description provided for @whichAmount.
  ///
  /// In fr, this message translates to:
  /// **'Quel montant ?'**
  String get whichAmount;

  /// No description provided for @expenseTitleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Intitulé de la dépense'**
  String get expenseTitleLabel;

  /// No description provided for @expenseTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Courses Carrefour'**
  String get expenseTitleHint;

  /// No description provided for @skipButton.
  ///
  /// In fr, this message translates to:
  /// **'Passer — utiliser \"{category}\"'**
  String skipButton(String category);

  /// No description provided for @forWho.
  ///
  /// In fr, this message translates to:
  /// **'Pour qui ?'**
  String get forWho;

  /// No description provided for @addBeneficiary.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un bénéficiaire'**
  String get addBeneficiary;

  /// No description provided for @addBeneficiaryHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Mamie, Enfants…'**
  String get addBeneficiaryHint;

  /// No description provided for @moreDetails.
  ///
  /// In fr, this message translates to:
  /// **'Plus de détails'**
  String get moreDetails;

  /// No description provided for @dateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @commentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get commentLabel;

  /// No description provided for @commentHint.
  ///
  /// In fr, this message translates to:
  /// **'Optionnel'**
  String get commentHint;

  /// No description provided for @tagsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @addExpenseButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la dépense'**
  String get addExpenseButton;

  /// No description provided for @editExpenseButton.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editExpenseButton;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la catégorie'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer \"{name}\" ?'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la dépense'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer \"{title}\" ?'**
  String deleteExpenseConfirm(String title);

  /// No description provided for @groupsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get groupsTitle;

  /// No description provided for @myGroupsSection.
  ///
  /// In fr, this message translates to:
  /// **'Mes groupes'**
  String get myGroupsSection;

  /// No description provided for @noGroupsText.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe pour l\'instant.'**
  String get noGroupsText;

  /// No description provided for @primaryBadge.
  ///
  /// In fr, this message translates to:
  /// **'Principal'**
  String get primaryBadge;

  /// No description provided for @activeBadge.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get activeBadge;

  /// No description provided for @adminBadge.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get adminBadge;

  /// No description provided for @memberCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{# membre} other{# membres}}'**
  String memberCount(int count);

  /// No description provided for @primaryTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Groupe principal'**
  String get primaryTooltip;

  /// No description provided for @setPrimaryTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Définir comme principal'**
  String get setPrimaryTooltip;

  /// No description provided for @manageGroupTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Gérer le groupe'**
  String get manageGroupTooltip;

  /// No description provided for @membersSection.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get membersSection;

  /// No description provided for @beneficiariesSection.
  ///
  /// In fr, this message translates to:
  /// **'Bénéficiaires'**
  String get beneficiariesSection;

  /// No description provided for @leaveGroupButton.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe'**
  String get leaveGroupButton;

  /// No description provided for @deleteGroupButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le groupe'**
  String get deleteGroupButton;

  /// No description provided for @transferAdminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transférer l\'administration'**
  String get transferAdminTitle;

  /// No description provided for @transferAdminMessage.
  ///
  /// In fr, this message translates to:
  /// **'Transférer le rôle d\'administrateur à {name} ?\nVous ne serez plus administrateur de ce groupe.'**
  String transferAdminMessage(String name);

  /// No description provided for @transferButton.
  ///
  /// In fr, this message translates to:
  /// **'Transférer'**
  String get transferButton;

  /// No description provided for @removeFromGroupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du groupe'**
  String get removeFromGroupTitle;

  /// No description provided for @removeFromGroupMessage.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {name} du groupe ?\n\n{name} restera bénéficiaire et continuera d\'apparaître dans les dépenses existantes.'**
  String removeFromGroupMessage(String name);

  /// No description provided for @removeButton.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeButton;

  /// No description provided for @removeBeneficiaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le bénéficiaire'**
  String get removeBeneficiaryTitle;

  /// No description provided for @removeBeneficiaryConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer \"{name}\" des bénéficiaires ?'**
  String removeBeneficiaryConfirm(String name);

  /// No description provided for @removeBeneficiaryWarning.
  ///
  /// In fr, this message translates to:
  /// **'{name} sera retiré(e) de toutes les dépenses du groupe. Ces dépenses peuvent se retrouver sans bénéficiaire.'**
  String removeBeneficiaryWarning(String name);

  /// No description provided for @leaveGroupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe'**
  String get leaveGroupTitle;

  /// No description provided for @leaveGroupLastMember.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes le seul membre. Quitter le groupe le supprimera définitivement.'**
  String get leaveGroupLastMember;

  /// No description provided for @leaveGroupAdminMessage.
  ///
  /// In fr, this message translates to:
  /// **'En quittant le groupe, {name} deviendra automatiquement administrateur.'**
  String leaveGroupAdminMessage(String name);

  /// No description provided for @leaveGroupConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment quitter \"{group}\" ?'**
  String leaveGroupConfirm(String group);

  /// No description provided for @leaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get leaveButton;

  /// No description provided for @deleteGroupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le groupe'**
  String get deleteGroupTitle;

  /// No description provided for @deleteGroupConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer \"{group}\" ?'**
  String deleteGroupConfirm(String group);

  /// No description provided for @deleteGroupWarning.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Toutes les dépenses et catégories seront supprimées définitivement.'**
  String get deleteGroupWarning;

  /// No description provided for @deletePermanentlyButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get deletePermanentlyButton;

  /// No description provided for @meSuffix.
  ///
  /// In fr, this message translates to:
  /// **'(moi)'**
  String get meSuffix;

  /// No description provided for @transferTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Transférer l\'administration à {name}'**
  String transferTooltip(String name);

  /// No description provided for @kickTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {name} du groupe'**
  String kickTooltip(String name);

  /// No description provided for @deleteBeneficiaryTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {name}'**
  String deleteBeneficiaryTooltip(String name);

  /// No description provided for @forLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pour :'**
  String get forLabel;

  /// No description provided for @deleteExpenseDialogConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer \"{title}\" ?'**
  String deleteExpenseDialogConfirm(String title);

  /// No description provided for @chooseCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une catégorie'**
  String get chooseCategoryTitle;

  /// No description provided for @newCategoryButton.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle\ncatégorie'**
  String get newCategoryButton;

  /// No description provided for @iconSectionFood.
  ///
  /// In fr, this message translates to:
  /// **'Alimentation'**
  String get iconSectionFood;

  /// No description provided for @iconSectionHousing.
  ///
  /// In fr, this message translates to:
  /// **'Logement'**
  String get iconSectionHousing;

  /// No description provided for @iconSectionTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get iconSectionTransport;

  /// No description provided for @iconSectionHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get iconSectionHealth;

  /// No description provided for @iconSectionEntertainment.
  ///
  /// In fr, this message translates to:
  /// **'Loisirs'**
  String get iconSectionEntertainment;

  /// No description provided for @iconSectionShopping.
  ///
  /// In fr, this message translates to:
  /// **'Shopping'**
  String get iconSectionShopping;

  /// No description provided for @iconSectionTech.
  ///
  /// In fr, this message translates to:
  /// **'Tech'**
  String get iconSectionTech;

  /// No description provided for @iconSectionOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get iconSectionOther;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
