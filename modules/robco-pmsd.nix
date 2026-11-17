# RobCo Media System — хост-демон pmsd для Pico с дисплеем SSD1322.
#
# Сам скрипт лежит в проекте на NTFS-диске, а тот монтируется через udisks
# только после входа в сессию. Поэтому сервис запускает не его, а копию из
# ~/.local/share/robco — её туда кладёт deploy.sh из проекта. Nix отвечает за
# всё остальное: Python с нужными модулями, утилиты и доступ к порту платы.
{ pkgs, ... }:

let
  python = pkgs.python3.withPackages (ps: with ps; [ pyserial pillow ]);

  # Как и сервис, обёртка смотрит на выложенную копию, а не на файл с NTFS-диска.
  pmsctl = pkgs.writeShellScriptBin "pmsctl" ''
    exec ${pkgs.python3}/bin/python3 "$HOME/.local/share/robco/pmsctl" "$@"
  '';
  ctl = "${pmsctl}/bin/pmsctl";

  # Колёсико громкости с Ctrl — как диск выбора у Pip-Boy. Без Ctrl оно
  # по-прежнему крутит громкость: KDE сравнивает комбинацию целиком.
  #
  # Хоткеи берутся из X-KDE-Shortcuts: kglobalacceld сам находит такие
  # .desktop-файлы. Это значения по умолчанию — переназначения из «Параметров
  # системы» KDE хранит в kglobalshortcutsrc, и Nix их не перетирает.
  # Компонент регистрируется, только если ключ есть у ОСНОВНОЙ записи,
  # поэтому на неё повешено нажатие колёсика, а повороты — действиями.
  pipboyKeys = pkgs.writeTextFile {
    name = "robco-pipboy-desktop";
    destination = "/share/applications/robco-pipboy.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=RobCo Pip-Boy
      Comment=Колёсико громкости с Ctrl управляет дисплеем RobCo Media System
      Icon=input-dialpad
      NoDisplay=true
      Exec=${ctl} sel enter
      X-KDE-Shortcuts=Ctrl+Volume Mute
      Actions=sel-next;sel-prev;tab-next;tab-prev;auto;

      [Desktop Action sel-next]
      Name=Курсор вниз
      Exec=${ctl} sel next
      X-KDE-Shortcuts=Ctrl+Volume Up

      [Desktop Action sel-prev]
      Name=Курсор вверх
      Exec=${ctl} sel prev
      X-KDE-Shortcuts=Ctrl+Volume Down

      [Desktop Action tab-next]
      Name=Следующая вкладка
      Exec=${ctl} tab next
      X-KDE-Shortcuts=Ctrl+Shift+Volume Up

      [Desktop Action tab-prev]
      Name=Предыдущая вкладка
      Exec=${ctl} tab prev
      X-KDE-Shortcuts=Ctrl+Shift+Volume Down

      [Desktop Action auto]
      Name=Выйти из ручного режима
      Exec=sh -c "${ctl} sel off; ${ctl} tab auto"
      X-KDE-Shortcuts=Ctrl+Shift+Volume Mute
    '';
  };
in
{
  # /dev/ttyACM* принадлежит группе dialout. Без неё pmsd не видит плату и
  # молчит об этом: ошибку открытия порта он глотает и пробует снова.
  users.users.misty.extraGroups = [ "dialout" ];

  # pmsctl в PATH — для терминала; хоткеи KDE вызывают его по полному пути.
  environment.systemPackages = [ pmsctl pipboyKeys ];

  systemd.user.services.robco-pmsd = {
    description = "RobCo Media System host daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" "pipewire.service" ];
    # Копию ещё не разложили — не стартуем вовсе, а не перезапускаемся впустую.
    unitConfig.ConditionPathExists = "%h/.local/share/robco/pmsd.py";

    path = with pkgs; [
      playerctl    # трек и статус плеера через MPRIS
      cava         # спектр для визуалайзера
      curl         # погода
      wireplumber  # wpctl — громкость
      pipewire     # pw-dump — формат аудиопотока
      iproute2
      iputils
      # niri и остальное из системы: pmsd ищет их через which
      "/run/current-system/sw"
    ];

    serviceConfig = {
      ExecStart = "${python}/bin/python3 -u %h/.local/share/robco/pmsd.py";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
