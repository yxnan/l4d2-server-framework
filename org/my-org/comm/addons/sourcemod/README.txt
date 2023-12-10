Common sourcemod directories shared by profiles.

Put your sourcemod installation here.

1. `bin` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/bin`
2. `configs` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/configs`
3. `extensions` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/extensions`
4. `plugins` ----mounted to---> `/L4D2/left4dead2/addons/sourcemod/plugins`

If you need to install a plugin which will be shared by all your profiles,
then put it into `plugins` here.
Otherwise, put it into profile-specific `plugins_custom` directory.

Other directories like `data`, `gamedata`, `logs`, `translations` will be
shadowed by profiles, hence should not be modified here.
