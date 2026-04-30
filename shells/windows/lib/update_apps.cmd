REM C:\msys64\msys2_shell.cmd -mingw64 -c "pacman -Syuu --noconfirm"
REM C:\msys64\msys2_shell.cmd -mingw64 -c "pacman -Syuu --noconfirm"
choco upgrade chocolatey -y
choco upgrade all -y
call "C:\texlive\2026\bin\windows\tlmgr.bat" update --self --all
python -m pip install --upgrade pip
pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U
echo ---- recording requirments in "%USERPROFILE%/requirements.txt" ----
pip freeze > "%USERPROFILE%/requirements.txt"
cat "%USERPROFILE%/requirements.txt"
pushd "C:\Users\jackd\source\repos\physics\Papers\discrete-causal-lattice"

