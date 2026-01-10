set mods=dsh.dbg dsh.ff dsh.tt dsh.vv
for %%m in (%mods%) do (
	cd %%m
	install.bat
	cd ..
)