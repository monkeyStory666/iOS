## Script to work with the strings and translations of the iOS MEGA apps (Main, VPN, Shared repo, and Password Manager) using Transifex.


### Initial configuration:

1) Clone this repository into the base of your iOS project
2) Create the file transifexConfig.json with the appropriate options for the project (see below)
3) Confirm the appropriate `x-resource.conf` file is present for your project
4) Use the script as required via the command line `./iosTransifex/iosTransifex.py`


#### transifexConfig.json options:

```
{
    "apiToken": "Your transifex accounts API token",
    "gitLabToken": "Your gitlab accounts API token",
    "botToken": "Optional transifex bot token for pruning (currently just the main iOS app is supported)",
    "botUrl": "Optional transifex bot URL value for pruning (currently just the main iOS app is supported)",
    "projectName": "The project name in Transifex where the projects strings are stored. This should match an existing x-resource.conf file e.g: ios-35 (main iOS app, shared repo), mega-vpn-ios (iOS VPN app), password-manager-ios (iOS Password app)",
    "gitId": "The Gitlab project id for the project the script is cloned into e.g: 193 (main iOS app), 283 (iOS VPN app), 303 (iOS Password app), 317 (shared repo)",
    "gitDefaultBranch": "The default branch for comparing string changes against e.g: develop, main, master",
    "langStorePath": "Partial file path to where the language files should be downloaded. Base.lproj or other language will be added to the end automatically e.g: Modules/Presentation/MEGAL10n/Sources/MEGAL10n/Resources/ (main iOS app)",
    "lib": "Set to true if this is the library/shared project. Can be skipped for other projects"
}
```
