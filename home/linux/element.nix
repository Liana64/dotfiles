{
  pkgs,
  inputs,
  ...
}: {
  programs.element-desktop = {
    enable = true;
    settings = {
      default_server_config = {
        "m.homeserver" = {
            base_url = "https://matrix.lianas.org";
            server_name = "lianas.org";
        };
        "m.identity_server" = {
            base_url = "https://vector.im";
        };
      };
      disable_custom_urls = false;
      disable_guests = false;
      disable_login_language_selector = false;
      disable_3pid_login = false;
      force_verification = false;
      brand = "Element";
      integrations_ui_url = "https://scalar.vector.im/";
      integrations_rest_url = "https://scalar.vector.im/api";
    };
  };
}
