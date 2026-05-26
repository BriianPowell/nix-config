# Rectangle settings for Brian_Powell (macOS).
# Add another file like this for each darwin home-manager user.
#
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
    # jsonConfig = ../../home/rectangle/RectangleConfig.json;
  };
}
