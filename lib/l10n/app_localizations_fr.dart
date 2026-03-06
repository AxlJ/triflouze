// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get add => 'Ajouter';

  @override
  String get close => 'Fermer';

  @override
  String get next => 'Suivant';

  @override
  String get user => 'Utilisateur';

  @override
  String errorPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String get loginTitle => 'Connexion';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get switchToSignIn => 'Déjà un compte ? Se connecter';

  @override
  String get switchToSignUp => 'Pas de compte ? S\'inscrire';

  @override
  String get orDivider => 'ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get errorGoogleCancelled => 'Connexion Google annulée.';

  @override
  String get errorGoogle => 'Erreur Google Sign-In. Veuillez réessayer.';

  @override
  String get errorEmptyFields => 'Merci de remplir tous les champs.';

  @override
  String get errorEmptyFirstName => 'Merci d\'entrer votre prénom.';

  @override
  String get errorInvalidCredential => 'Email ou mot de passe incorrect.';

  @override
  String get errorEmailInUse => 'Cet email est déjà utilisé.';

  @override
  String get errorWeakPassword =>
      'Mot de passe trop faible (min. 6 caractères).';

  @override
  String get errorInvalidEmail => 'Adresse email invalide.';

  @override
  String get errorUnknown => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get myGroupTitle => 'Mon groupe';

  @override
  String get welcomeTitle => 'Bienvenue !';

  @override
  String get welcomeSubtitle => 'Créez un groupe ou rejoignez-en un existant.';

  @override
  String get createGroupTitle => 'Créer un groupe';

  @override
  String get groupNameLabel => 'Nom du groupe';

  @override
  String get groupNameHint => 'Ex : Famille Dupont';

  @override
  String get createButton => 'Créer';

  @override
  String get joinGroupTitle => 'Rejoindre un groupe';

  @override
  String get groupCodeLabel => 'Code à 6 caractères';

  @override
  String get groupCodeHint => 'Ex : ABC123';

  @override
  String get joinButton => 'Rejoindre';

  @override
  String get errorInvalidCode => 'Code invalide. Vérifiez et réessayez.';

  @override
  String errorGroupCreation(String error) {
    return 'Erreur lors de la création : $error';
  }

  @override
  String errorGroupJoin(String error) {
    return 'Erreur lors de la jonction : $error';
  }

  @override
  String get createGroupButton => 'Créer le groupe';

  @override
  String get errorEmptyGroupName => 'Entrez un nom de groupe.';

  @override
  String get errorEmptyCode => 'Entrez un code de groupe.';

  @override
  String get settingsTooltip => 'Paramètres groupes';

  @override
  String get inviteTooltip => 'Inviter';

  @override
  String get logoutTooltip => 'Se déconnecter';

  @override
  String get inviteDialogTitle => 'Inviter quelqu\'un';

  @override
  String get inviteDialogSubtitle =>
      'Partage ce code pour rejoindre le groupe :';

  @override
  String get copyButton => 'Copier';

  @override
  String get codeCopied => 'Code copié !';

  @override
  String get totalExpenses => 'Total des dépenses (en €)';

  @override
  String get noExpensesForPeriod => 'Aucune dépense pour cette période';

  @override
  String get viewDetails => 'Voir le détail';

  @override
  String get filterAll => 'Toujours';

  @override
  String get filterToday => 'Ce jour';

  @override
  String get filterThisWeek => 'Cette semaine';

  @override
  String get filterThisMonth => 'Ce mois';

  @override
  String get filterThisYear => 'Cette année';

  @override
  String get filterAllMembers => 'Tous';

  @override
  String get filterAllCategories => 'Toutes';

  @override
  String get deleteBeneficiaryTitle => 'Supprimer le bénéficiaire';

  @override
  String deleteBeneficiaryConfirm(String name) {
    return 'Voulez-vous supprimer \"$name\" de la liste ?';
  }

  @override
  String get statisticsTitle => 'Statistiques';

  @override
  String get categoryBreakdown => 'Répartition par catégorie';

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# dépenses',
      one: '# dépense',
    );
    return '$_temp0';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get whichCategory => 'Quelle catégorie ?';

  @override
  String get addCategoryTile => 'Ajouter';

  @override
  String get newCategoryTitle => 'Nouvelle catégorie';

  @override
  String get categoryNameLabel => 'Nom';

  @override
  String get chooseIcon => 'Choisir une icône :';

  @override
  String get whichAmount => 'Quel montant ?';

  @override
  String get expenseTitleLabel => 'Intitulé de la dépense';

  @override
  String get expenseTitleHint => 'Ex: Courses Carrefour';

  @override
  String skipButton(String category) {
    return 'Passer — utiliser \"$category\"';
  }

  @override
  String get forWho => 'Pour qui ?';

  @override
  String get addBeneficiary => 'Ajouter un bénéficiaire';

  @override
  String get addBeneficiaryHint => 'Ex: Mamie, Enfants…';

  @override
  String get moreDetails => 'Plus de détails';

  @override
  String get dateLabel => 'Date';

  @override
  String get commentLabel => 'Commentaire';

  @override
  String get commentHint => 'Optionnel';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get addExpenseButton => 'Ajouter la dépense';

  @override
  String get editExpenseButton => 'Modifier';

  @override
  String get deleteCategoryTitle => 'Supprimer la catégorie';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String get deleteExpenseTitle => 'Supprimer la dépense';

  @override
  String deleteExpenseConfirm(String title) {
    return 'Supprimer \"$title\" ?';
  }

  @override
  String get groupsTitle => 'Groupes';

  @override
  String get myGroupsSection => 'Mes groupes';

  @override
  String get noGroupsText => 'Aucun groupe pour l\'instant.';

  @override
  String get primaryBadge => 'Principal';

  @override
  String get activeBadge => 'Actif';

  @override
  String get adminBadge => 'Admin';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# membres',
      one: '# membre',
    );
    return '$_temp0';
  }

  @override
  String get primaryTooltip => 'Groupe principal';

  @override
  String get setPrimaryTooltip => 'Définir comme principal';

  @override
  String get manageGroupTooltip => 'Gérer le groupe';

  @override
  String get membersSection => 'Membres';

  @override
  String get beneficiariesSection => 'Bénéficiaires';

  @override
  String get leaveGroupButton => 'Quitter le groupe';

  @override
  String get deleteGroupButton => 'Supprimer le groupe';

  @override
  String get transferAdminTitle => 'Transférer l\'administration';

  @override
  String transferAdminMessage(String name) {
    return 'Transférer le rôle d\'administrateur à $name ?\nVous ne serez plus administrateur de ce groupe.';
  }

  @override
  String get transferButton => 'Transférer';

  @override
  String get removeFromGroupTitle => 'Retirer du groupe';

  @override
  String removeFromGroupMessage(String name) {
    return 'Retirer $name du groupe ?\n\n$name restera bénéficiaire et continuera d\'apparaître dans les dépenses existantes.';
  }

  @override
  String get removeButton => 'Retirer';

  @override
  String get removeBeneficiaryTitle => 'Supprimer le bénéficiaire';

  @override
  String removeBeneficiaryConfirm(String name) {
    return 'Supprimer \"$name\" des bénéficiaires ?';
  }

  @override
  String removeBeneficiaryWarning(String name) {
    return '$name sera retiré(e) de toutes les dépenses du groupe. Ces dépenses peuvent se retrouver sans bénéficiaire.';
  }

  @override
  String get leaveGroupTitle => 'Quitter le groupe';

  @override
  String get leaveGroupLastMember =>
      'Vous êtes le seul membre. Quitter le groupe le supprimera définitivement.';

  @override
  String leaveGroupAdminMessage(String name) {
    return 'En quittant le groupe, $name deviendra automatiquement administrateur.';
  }

  @override
  String leaveGroupConfirm(String group) {
    return 'Voulez-vous vraiment quitter \"$group\" ?';
  }

  @override
  String get leaveButton => 'Quitter';

  @override
  String get deleteGroupTitle => 'Supprimer le groupe';

  @override
  String deleteGroupConfirm(String group) {
    return 'Supprimer \"$group\" ?';
  }

  @override
  String get deleteGroupWarning =>
      'Cette action est irréversible. Toutes les dépenses et catégories seront supprimées définitivement.';

  @override
  String get deletePermanentlyButton => 'Supprimer définitivement';

  @override
  String get meSuffix => '(moi)';

  @override
  String transferTooltip(String name) {
    return 'Transférer l\'administration à $name';
  }

  @override
  String kickTooltip(String name) {
    return 'Retirer $name du groupe';
  }

  @override
  String deleteBeneficiaryTooltip(String name) {
    return 'Supprimer $name';
  }

  @override
  String get forLabel => 'Pour :';

  @override
  String deleteExpenseDialogConfirm(String title) {
    return 'Voulez-vous supprimer \"$title\" ?';
  }

  @override
  String get chooseCategoryTitle => 'Choisir une catégorie';

  @override
  String get newCategoryButton => 'Nouvelle\ncatégorie';

  @override
  String get iconSectionFood => 'Alimentation';

  @override
  String get iconSectionHousing => 'Logement';

  @override
  String get iconSectionTransport => 'Transport';

  @override
  String get iconSectionHealth => 'Santé';

  @override
  String get iconSectionEntertainment => 'Loisirs';

  @override
  String get iconSectionShopping => 'Shopping';

  @override
  String get iconSectionTech => 'Tech';

  @override
  String get iconSectionOther => 'Autres';
}
