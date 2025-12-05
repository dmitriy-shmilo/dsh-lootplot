for /D %%s in (.\*) do (
	echo "%APPDATA%\lootplot\mods\%%s\"
	xcopy /r /y /e %%s %APPDATA%\lootplot\mods\%%s\	
)