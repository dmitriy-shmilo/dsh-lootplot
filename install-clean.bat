rmdir /s /q %APPDATA%\lootplot\mods
mkdir %APPDATA%\lootplot\mods

for /D %%s in (.\*) do (
	xcopy /r /y /e %%s %APPDATA%\lootplot\mods\%%s\
)