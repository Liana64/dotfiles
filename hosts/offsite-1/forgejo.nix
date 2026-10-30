{
  config,
  inputs,
  ...
}: let
  addr = inputs.self.network.offsite.hosts.${config.networking.hostName};
  domain = "forge.milberry.org";
  cert = config.security.acme.certs.${domain}.directory;
in {
  motd.commands = [["https://${domain}" "Forgejo"]];

  sops.secrets."services/acme/cloudflare.env" = {
    owner = "acme";
    mode = "0400";
  };

  security.acme = {
    acceptTerms = true;
    certs.${domain} = {
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = config.sops.secrets."services/acme/cloudflare.env".path;
      group = "forgejo";
      reloadServices = ["forgejo.service"];
    };
  };

  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    settings = {
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
        PROTOCOL = "https";
        HTTP_ADDR = addr;
        HTTP_PORT = 3000;
        CERT_FILE = "${cert}/fullchain.pem";
        KEY_FILE = "${cert}/key.pem";
        START_SSH_SERVER = true;
        SSH_DOMAIN = domain;
        SSH_LISTEN_HOST = addr;
        SSH_PORT = 2222;
        SSH_LISTEN_PORT = 2222;
        OFFLINE_MODE = true;
        LANDING_PAGE = "login";
      };
      service = {
        DISABLE_REGISTRATION = true;
        REQUIRE_SIGNIN_VIEW = true;
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
        ENABLE_NOTIFY_MAIL = false;
      };
      security = {
        INSTALL_LOCK = true;
        TWO_FACTOR_AUTH = "enforced";
        PASSWORD_HASH_ALGO = "argon2";
        MIN_PASSWORD_LENGTH = 16;
        LOGIN_REMEMBER_DAYS = 1;
        DISABLE_WEBHOOKS = true;
      };
      session.COOKIE_SECURE = true;
      openid = {
        ENABLE_OPENID_SIGNIN = false;
        ENABLE_OPENID_SIGNUP = false;
      };
      oauth2.ENABLED = false;
      repository = {
        DEFAULT_PRIVATE = "private";
        FORCE_PRIVATE = true;
      };
      migrations.ALLOWED_DOMAINS = inputs.self.network.cluster.hosts.m1;
      api.ENABLE_SWAGGER = false;
      other.SHOW_FOOTER_VERSION = false;
      actions.ENABLED = false;
      packages.ENABLED = false;
      mailer.ENABLED = false;
      "cron.update_checker".ENABLED = false;
      log.LEVEL = "Warn";
    };
  };

  systemd.services.forgejo = {
    after = ["network-online.target" "acme-${domain}.service"];
    wants = ["network-online.target" "acme-${domain}.service"];
  };
}
