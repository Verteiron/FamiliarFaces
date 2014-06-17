call build_bsa_deps.cmd
call build_7z_deps.cmd
ping -n 1 -w 1000 1.0.0.0 > nul
rmdir /s /q datadep