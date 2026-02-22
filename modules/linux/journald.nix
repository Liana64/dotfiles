{ ... }: {
  services.journald.extraConfig = ''
    Storage=persistent
  '';
}
