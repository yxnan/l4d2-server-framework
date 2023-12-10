Profile-specific sourcemod directories.

Install your plugins here.

1. `data` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/data`
2. `gamedata` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/gamedata`
3. `logs` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/logs`
4. `plugins_custom` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/plugins/custom`
5. `translations` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/translations`

Here we abuse the fact that sourcemod will recursively find every *.smx files under
`plugins` and load them, so we can mount our profile-specific plugins to a
subdirectory `custom` (name doesn't matter, just serves as a hint)

Notice that some sourcemod directories are missing here, like `bin`, `scripting`,
`configs`, `extensions`, etc. This is because:

1. `bin`: rarely modified, and should be commonly shared by all profiles,
    hence belongs to `org`.
2. `extensions`: same as above.
3. `configs`: holds admin list, which we usually want to share across profiles.
4. `scripting`: for dev-only purposes, if you need, managing them separately
    makes more sense.
