set mods=dsh.dbg dsh.ff dsh.tt dsh.vv dsh.qq dsh.dd
for %%m in (%mods%) do (
	cd %%m
	install.bat
	cd ..
)