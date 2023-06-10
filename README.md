# README.md

This is a pared down version of my main desktop .dotfiles that can be deployed to servers with minimal impact on the server itself. No software is installed or downloaded automatically - one must manually run the `install_ubuntu_base_software.sh` or `install_common_binaries.sh` scripts. The `install_common_binaries.sh` script assumes curl is available in your path.

## Updating Submodules

Run the following commands to update any remote submodules:

```zsh
git submodule update --remote
git status
git add #folders that changed
git commit -m "update submodules to latest remote version"
# then check out other branches and merge main
```

