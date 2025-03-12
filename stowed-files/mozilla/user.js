// Firefox user settings
//
// Installation
//
// Windows: %APPDATA%\Mozilla\Firefox\Profiles\<profile folder>\user.js
// Linux: ~/.mozilla/firefox/<profile folder>/user.js (done via `stow` script)
// MacOS: ~/Library/Application Support/Firefox/Profiles/<profile folder>/user.js

// Skip first run stuff
user_pref('app.normandy.first_run', false);
user_pref('browser.aboutwelcome.didSeeFinalScreen', true);

user_pref('browser.bookmarks.restore_default_bookmarks', false);
user_pref('browser.bookmarks.showMobileBookmarks', true);

user_pref('browser.contentblocking.category', 'standard');

user_pref('browser.shell.checkDefaultBrowser', false);

user_pref('browser.discovery.enabled', false);

user_pref('browser.toolbarbuttons.introduced.sidebar-button', true);
user_pref('browser.toolbars.bookmarks.visibility', 'never');

// Use 1Password
user_pref('extensions.formautofill.creditCards.enabled', false);
user_pref('services.sync.declinedEngines', ['addresses', 'creditcards', 'passwords']);
user_pref('services.sync.engine.passwords', false);

// AI settings
user_pref('browser.ml.chat.enabled', true);
user_pref('browser.ml.chat.provider', 'https://claude.ai/new');
user_pref('browser.ml.chat.sidebar', true);

// Sidebar settings
user_pref('sidebar.backupState', {
  'command': '',
  'launcherWidth': 0,
  'launcherExpanded': false,
  'launcherVisible': false,
});
user_pref('sidebar.main.tools', ['aichat', 'bookmarks', 'syncedtabs']);
user_pref('sidebar.revamp', true);
user_pref('sidebar.verticalTabs', true);

// Disable search suggestions in search bar
user_user_pref("browser.urlbar.quicksuggest.sponsored", false);
user_user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);

// Disable sponsored in new tab
user_user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_user_pref("browser.newtabpage.activity-stream.topSitesRows", 4);
