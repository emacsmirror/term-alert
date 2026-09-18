{
  lib,
  templateLib,
  config,
  ...
}:
let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    ;
  inherit (lib.strings) escapeShellArg join;
  inherit (lib.types) toml;
  inherit (templateLib.types) relativePath;

  cfg = config.template.tools.mypy;
  python = config.template.languages.python;

  targetVersion = python.minVersion;
in
{
  options.template.tools.mypy = {
    enable = mkEnableOption "enable";

    stubDir = mkOption {
      type = relativePath;
      default = "stubs";
    };

    config = mkOption {
      type = toml;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    git-hooks.hooks.mypy = {
      enable = true;
      name = "python: typecheck";
      entry = join " " [
        "${getExe config.languages.python.uv.package}"
        "run"
        "mypy"
        "--python-version"
        "${escapeShellArg targetVersion}"
      ];
      types_or = python.fileTags;
      require_serial = true;
    };

    template = {
      languages.python = {
        seedDevDependencies = {
          mypy = "==2.3.1";
        };
        config.tool.mypy = cfg.config;
      };

      tools.mypy.config = {
        explicit_package_bases = !python.isPackage;
        mypy_path = cfg.stubDir;
        namespace_packages = !python.isPackage;
        pretty = true;
        python_version = targetVersion;
        scripts_are_modules = true;
        strict = true;
      };

      clean.deepCleanCommands = [ "rm -rf .mypy_cache" ];
    };
  };
}
