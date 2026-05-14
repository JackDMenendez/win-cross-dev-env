call msys64.cmd -c "update-packages.sh"
type "%USERPROFILE%\msys64-packages.txt"
echo ---- Updating Winget Apps ----
winget upgrade --all --include-unknown

echo ---- Updating Chocolatey Apps ----
choco upgrade chocolatey -y
choco upgrade all -y

echo ---- List of Installed Winget Apps ----
winget list > "%USERPROFILE%\winget-apps.txt"
type "%USERPROFILE%\winget-apps.txt"

echo ---- List of Installed Chocolatey Apps ----
choco list --local-only > "%USERPROFILE%\choco-apps.txt"
type "%USERPROFILE%\choco-apps.txt"
call "C:\texlive\2026\bin\windows\tlmgr.bat" update --self --all
call "C:\texlive\2026\bin\windows\tlmgr.bat" list --only-installed > "%USERPROFILE%\texlive-packages.txt"
type "%USERPROFILE%\texlive-packages.txt"
python -m pip install --upgrade pip
pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U
echo ---- recording requirments in "%USERPROFILE%/requirements.txt" ----
pip freeze > "%USERPROFILE%/requirements.txt"
cat "%USERPROFILE%/requirements.txt"
pushd "C:\Users\jackd\source\repos\physics\Papers\discrete-causal-lattice"

