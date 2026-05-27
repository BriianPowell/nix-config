# Rectangle settings for boog (macOS).
{ ... }:
{
  programs.rectangle = {
    enable = true;

    settings = {
      alternateDefaultShortcuts = true;
      launchOnLogin = true;
      subsequentExecutionMode = 1;
      disabledApps = ''["com.apple.systempreferences"]'';
      reflowTodo = {
        keyCode = 45;
        modifierFlags = 786432;
      };
      toggleTodo = {
        keyCode = 11;
        modifierFlags = 786432;
      };
      showExportImport = true;
    };

    bootstrapJson = false;
    jsonConfig = null;
  };
}
