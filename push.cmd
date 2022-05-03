SET src_folder=./site
SET move_to_folder=./

git checkout main -- docs
git checkout main -- mkdocs.yml
mkdocs build
@REM pause

for /f %%a IN ('dir "%src_folder%" /b') do move "%src_folder%\%%a" "%move_to_folder%\"
@REM pause

rm -rf ./docs
@REM pause

del mkdocs.yml
@REM pause

