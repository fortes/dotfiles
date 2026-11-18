* Before anything else, run `make setup` and then `make doctor`, which says how to fix anything missing
* `make check` runs every check; run it before committing
* Pin tool versions in the files `script/setup` reads, and keep dependencies in lock files, so every environment (dev containers, CI, cloud agents) gets the same ones
* In dev containers, run dev servers on `0.0.0.0` at `$PORT`; `$DEV_URL` is the address to open from the host or the LAN
