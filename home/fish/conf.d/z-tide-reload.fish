# Runs after plugin-tide.fish so tide functions exist.
if status is-interactive
    if functions -q _tide_detect_os
        set -U tide_os_icon (_tide_detect_os | head -n 1)
    end

    if functions -q _tide_remove_unusable_items
        _tide_remove_unusable_items
    end

    if functions -q _tide_cache_variables
        _tide_cache_variables
    end

    if functions -q _tide_sub_reload
        _tide_sub_reload
    end
end
