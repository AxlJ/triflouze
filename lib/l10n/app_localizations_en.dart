// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get user => 'User';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get switchToSignUp => 'No account? Sign up';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get errorGoogleCancelled => 'Google sign-in cancelled.';

  @override
  String get errorGoogle => 'Google Sign-In error. Please try again.';

  @override
  String get errorEmptyFields => 'Please fill in all fields.';

  @override
  String get errorEmptyFirstName => 'Please enter your first name.';

  @override
  String get errorInvalidCredential => 'Incorrect email or password.';

  @override
  String get errorEmailInUse => 'This email is already in use.';

  @override
  String get errorWeakPassword => 'Password too weak (min. 6 characters).';

  @override
  String get errorInvalidEmail => 'Invalid email address.';

  @override
  String get errorUnknown => 'An error occurred. Please try again.';

  @override
  String get myGroupTitle => 'My group';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get welcomeSubtitle => 'Create a group or join an existing one.';

  @override
  String get createGroupTitle => 'Create a group';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameHint => 'E.g. Smith Family';

  @override
  String get createButton => 'Create';

  @override
  String get joinGroupTitle => 'Join a group';

  @override
  String get groupCodeLabel => '6-character code';

  @override
  String get groupCodeHint => 'E.g. ABC123';

  @override
  String get joinButton => 'Join';

  @override
  String get errorInvalidCode => 'Invalid code. Please check and try again.';

  @override
  String errorGroupCreation(String error) {
    return 'Error creating group: $error';
  }

  @override
  String errorGroupJoin(String error) {
    return 'Error joining group: $error';
  }

  @override
  String get createGroupButton => 'Create group';

  @override
  String get errorEmptyGroupName => 'Enter a group name.';

  @override
  String get errorEmptyCode => 'Enter a group code.';

  @override
  String get settingsTooltip => 'Group settings';

  @override
  String get inviteTooltip => 'Invite';

  @override
  String get logoutTooltip => 'Sign out';

  @override
  String get inviteDialogTitle => 'Invite someone';

  @override
  String get inviteDialogSubtitle => 'Share this code to join the group:';

  @override
  String get copyButton => 'Copy';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get totalExpenses => 'Total expenses (in €)';

  @override
  String get noExpensesForPeriod => 'No expenses for this period';

  @override
  String get viewDetails => 'View details';

  @override
  String get filterAll => 'All time';

  @override
  String get filterToday => 'Today';

  @override
  String get filterThisWeek => 'This week';

  @override
  String get filterThisMonth => 'This month';

  @override
  String get filterThisYear => 'This year';

  @override
  String get filterAllMembers => 'All';

  @override
  String get filterAllCategories => 'All';

  @override
  String get deleteBeneficiaryTitle => 'Remove beneficiary';

  @override
  String deleteBeneficiaryConfirm(String name) {
    return 'Remove \"$name\" from the list?';
  }

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get categoryBreakdown => 'Breakdown by category';

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# expenses',
      one: '# expense',
    );
    return '$_temp0';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get whichCategory => 'Which category?';

  @override
  String get addCategoryTile => 'Add';

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get chooseIcon => 'Choose an icon:';

  @override
  String get whichAmount => 'How much?';

  @override
  String get expenseTitleLabel => 'Expense title';

  @override
  String get expenseTitleHint => 'E.g. Grocery shopping';

  @override
  String skipButton(String category) {
    return 'Skip — use \"$category\"';
  }

  @override
  String get forWho => 'For whom?';

  @override
  String get addBeneficiary => 'Add a beneficiary';

  @override
  String get addBeneficiaryHint => 'E.g. Grandma, Kids…';

  @override
  String get moreDetails => 'More details';

  @override
  String get dateLabel => 'Date';

  @override
  String get commentLabel => 'Comment';

  @override
  String get commentHint => 'Optional';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get addExpenseButton => 'Add expense';

  @override
  String get editExpenseButton => 'Edit';

  @override
  String get deleteCategoryTitle => 'Delete category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteExpenseTitle => 'Delete expense';

  @override
  String deleteExpenseConfirm(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get groupsTitle => 'Groups';

  @override
  String get myGroupsSection => 'My groups';

  @override
  String get noGroupsText => 'No groups yet.';

  @override
  String get primaryBadge => 'Primary';

  @override
  String get activeBadge => 'Active';

  @override
  String get adminBadge => 'Admin';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# members',
      one: '# member',
    );
    return '$_temp0';
  }

  @override
  String get primaryTooltip => 'Primary group';

  @override
  String get setPrimaryTooltip => 'Set as primary';

  @override
  String get manageGroupTooltip => 'Manage group';

  @override
  String get membersSection => 'Members';

  @override
  String get beneficiariesSection => 'Beneficiaries';

  @override
  String get leaveGroupButton => 'Leave group';

  @override
  String get deleteGroupButton => 'Delete group';

  @override
  String get transferAdminTitle => 'Transfer administration';

  @override
  String transferAdminMessage(String name) {
    return 'Transfer admin role to $name?\nYou will no longer be administrator of this group.';
  }

  @override
  String get transferButton => 'Transfer';

  @override
  String get removeFromGroupTitle => 'Remove from group';

  @override
  String removeFromGroupMessage(String name) {
    return 'Remove $name from the group?\n\n$name will remain a beneficiary and continue to appear in existing expenses.';
  }

  @override
  String get removeButton => 'Remove';

  @override
  String get removeBeneficiaryTitle => 'Remove beneficiary';

  @override
  String removeBeneficiaryConfirm(String name) {
    return 'Remove \"$name\" from beneficiaries?';
  }

  @override
  String removeBeneficiaryWarning(String name) {
    return '$name will be removed from all group expenses. These expenses may end up with no beneficiary.';
  }

  @override
  String get leaveGroupTitle => 'Leave group';

  @override
  String get leaveGroupLastMember =>
      'You are the only member. Leaving will permanently delete the group.';

  @override
  String leaveGroupAdminMessage(String name) {
    return 'By leaving, $name will automatically become the administrator.';
  }

  @override
  String leaveGroupConfirm(String group) {
    return 'Are you sure you want to leave \"$group\"?';
  }

  @override
  String get leaveButton => 'Leave';

  @override
  String get deleteGroupTitle => 'Delete group';

  @override
  String deleteGroupConfirm(String group) {
    return 'Delete \"$group\"?';
  }

  @override
  String get deleteGroupWarning =>
      'This action is irreversible. All expenses and categories will be permanently deleted.';

  @override
  String get deletePermanentlyButton => 'Delete permanently';

  @override
  String get meSuffix => '(me)';

  @override
  String transferTooltip(String name) {
    return 'Transfer admin to $name';
  }

  @override
  String kickTooltip(String name) {
    return 'Remove $name from group';
  }

  @override
  String deleteBeneficiaryTooltip(String name) {
    return 'Remove $name';
  }

  @override
  String get forLabel => 'For:';

  @override
  String deleteExpenseDialogConfirm(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get chooseCategoryTitle => 'Choose a category';

  @override
  String get newCategoryButton => 'New\ncategory';

  @override
  String get iconSectionFood => 'Food';

  @override
  String get iconSectionHousing => 'Housing';

  @override
  String get iconSectionTransport => 'Transport';

  @override
  String get iconSectionHealth => 'Health';

  @override
  String get iconSectionEntertainment => 'Entertainment';

  @override
  String get iconSectionShopping => 'Shopping';

  @override
  String get iconSectionTech => 'Tech';

  @override
  String get iconSectionOther => 'Other';
}
