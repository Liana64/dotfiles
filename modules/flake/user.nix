# @desc: Primary user identity; passed as `user` to flake, NixOS and home-manager modules
{
  _module.args.user = {
    name = "liana";
    uid = 1000;
    fullName = "Liana";
    email = "liana@lianas.org";
    signingKey = "2348524E0BC72DAD1638EC79EEE4B7E49941B009";
  };
}
