# @desc: Declares the dendritic aspect store flake.modules.<class>.<aspect>
# deferredModule lets many files merge into one <class>.<aspect>.
{lib, ...}: {
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = {};
  };
}
