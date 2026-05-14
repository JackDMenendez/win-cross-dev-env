# update-packages.sh - Update MSYS2 packages and export list of explicitly installed packages
# This script is intended to be run inside an MSYS2 shell. It will update all packages and 
# then export a list of explicitly installed packages to msys64-packages.txt in the current 
# directory.
pacman -Syu  # Update package database and core system packages first could cause a restart of 
#              the shell, so we do it in two steps to ensure we get the latest package database 
#              and core system packages before updating everything else.
pacman -Su --noconfirm # Update all packages without asking for confirmation    
pacman -Qe > "$PWD/msys64-packages.txt" # Export list of explicitly installed packages to a 
#                                         textfile in the current directory. This can be used