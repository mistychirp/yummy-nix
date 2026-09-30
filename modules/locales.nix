{ ... }:

# By default NixOS only generates the glibc locale archive for
# i18n.defaultLocale (en_US.UTF-8) plus C/POSIX, unlike most distros which
# ship a much broader set. That leaves ru_RU.UTF-8 unavailable, so anything
# relying on the host locale to pick a codepage (e.g. Wine running old
# CP1251 Delphi/C++Builder apps) falls back to Western encoding and renders
# Cyrillic text as mojibake. Adding it here makes it generatable without
# changing the system default locale.
{
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];
}
