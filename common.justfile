set allow-duplicate-recipes
set allow-duplicate-variables

id := `grep -Po "(?<=\"id\": \").*(?=\",$)" src/umg_mod.json`
version := `grep -Po "(?<=\"version\": \").*(?=\",$)" src/umg_mod.json`
idversion := f'{{id}}-{{version}}'

create_archive := "tar.exe -acf"

alias d := distribute
alias dist := distribute

# Destructive. Create an `id-version.zip` file in the given destination folder.
distribute dest:
	just undistribute {{dest}}
	just build {{dest}}
	cd {{dest}} && {{create_archive}} "{{idversion}}.zip" "{{id}}"
	just clean {{dest}}

# Destructive. Removed artifacts, created by `distribute` from the destination folder.
undistribute dest:
	rm -f {{dest}}/{{idversion}}.zip

# Destructive. Removes folders, which were created by `build`.
clean dest:
	rm -rf {{dest}}/{{id}}