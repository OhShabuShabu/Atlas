{ config, pkgs, lib, ... }:

{
    home.file = {
        ".mullvad/mullvadbrowser/ni1fxr3o.default-release/chrome".source  = ../privacy/mullvad-browser/ni1fxr3o.default-release/chrome;
        ".mullvad/mullvadbrowser/ni1fxr3o.default-release/extensions".source  = ../privacy/mullvad-browser/ni1fxr3o.default-release/extensions;
        ".mullvad/mullvadbrowser/ni1fxr3o.default-release/extensions.json".source  = ../privacy/mullvad-browser/ni1fxr3o.default-release/extensions.json;
        ".mullvad/mullvadbrowser/ni1fxr3o.default-release/extension-settings.json".source  = ../privacy/mullvad-browser/ni1fxr3o.default-release/extension-settings.json;
        ".mullvad/mullvadbrowser/ni1fxr3o.default-release/prefs.js".source  = ../privacy/mullvad-browser/ni1fxr3o.default-release/prefs.js;
        ".mullvad/mullvadbrowser/ni1fxr3o.default-release/extension-preferences.json".source  = ../privacy/mullvad-browser/ni1fxr3o.default-release/extension-preferences.json;

        ".mullvad/mullvadbrowser/profiles.ini".source  = ../privacy/mullvad-browser/profiles.ini;
        ".mullvad/mullvadbrowser/installs.ini".source  = ../privacy/mullvad-browser/installs.ini;

        ".mullvad/mullvadbrowser/ni1fxr3o.default-release/xulstore.json".source  = ../privacy/mullvad-browser/ni1fxr3o.default-release/xulstore.json;
        ".mullvad/mullvadbrowser/ni1fxr3o.default-release/addonStartup.json.lz4".source  = ../privacy/mullvad-browser/ni1fxr3o.default-release/addonStartup.json.lz4;
    };
}    