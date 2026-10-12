# Build the installer ISO in the cwd
[group('hardware')]
installer *args:
    cd {{ invocation_directory() }} && nix-build-installer {{ args }}

# Update firmware
[group('hardware')]
firmware:
    -fwupdmgr refresh
    fwupdmgr update

# Report SMART health
[group('hardware')]
smart:
    sudo smartctl -a /dev/nvme0n1
