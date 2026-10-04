dist_dir := f'{{invocation_directory()}}/dist/'
install_dir := `echo "${APPDATA//\\\\//}/lootplot/mods"`
children := "dsh.cc dsh.dbg dsh.dd dsh.ff dsh.qq dsh.tt dsh.vv"

alias i := install
alias d := distribute
alias dist := distribute

# Destructive. Invokes `distribute` for all children.
distribute:
	@for item in {{children}}; do just $item/distribute {{dist_dir}}; done

install:
	@for item in {{children}}; do just $item/build {{install_dir}}; done