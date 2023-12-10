# Versatile L4d2 Docker

This repo provides a framework to build a multi-instance L4D2 server clusters.

# Table of Contents

1. [Rationale](#Rationale)
2. [Brief](#Brief)
3. [Setup](#Setup)
4. [Custom hierarchy](#Custom-hierarchy)
5. [Todos](#Todos)

# Rationale

Setting up a L4D2 server is easy, since there are already tons of articles covering this topic.
But managing one is not quite trivial, especially when you have multiple servers,
each with slightly different configurations, or totally different plugin sets altogether.

For example, if you have 2 servers, sharing the same game installation,
while having one particular sourcemod plugin load in one but not the other,
you could just create a separate `server2.cfg`,
write the command to unload the plugin,
and designate it as the server config file
via command-line arg `+servercfgfile server2.cfg`. Ez!

This works, but it scales poorly, as more and more different configs arise,
this simple manual state-management approach will quickly leads to an incomprehensible
abomination. Plus it encourages small ad-hoc modifications, which are often left
undocumented and explode when you try to redeploy the setup on another machine.

Hence this repo aims to create a server deploy framework that catch these ephemeral states,
making them explicit and easy to manage.

# Brief

This framework provides a three-layer hierarchy:

1. `game`: serves as the game root, it's download from Valve as-is,
and we don't need to, and shouldn't touch it.

2. `org`: the boundary of managed configurations,
can hold multiple `profile`s, and common settings shared by all the
child `profiles`.

3. `profile`: the smallest configuration unit,
inherits the common settings from its parent `org`, plus some fine-tune configs
only belongs to itself. One `profile` == one running l4d2 instance.

Here is the graph showing how they are structured and mounted as a docker volume:
(Click to see detailed description for each directory)

<pre>
<code>
.
└── org
    ├── my-org
    │   ├── comm
    │   │   ├── <a href="versatile-l4d2-docker/tree/main/org/my-org/comm/addons/">addons</a>    ->  /L4D2/left4dead2/addons (install custom campaigns, sourcemods etc. here)
    │   │   ├── <a href="versatile-l4d2-docker/tree/main/org/my-org/comm/cfg_comm/">cfg_comm</a>  ->  /L4D2/left4dead2/cfg/comm (some reusable configs by profiles)
    │   │   ├── <a href="versatile-l4d2-docker/tree/main/org/my-org/comm/downloads/">downloads</a> ->  /L4D2/left4dead2/downloads
    │   │   └── <a href="versatile-l4d2-docker/tree/main/org/my-org/comm/ems/">ems</a>       ->  /L4D2/left4dead2/ems
    │   └── profiles
    │       ├── server1
    │       │   ├── <a href="versatile-l4d2-docker/tree/main/org/my-org/profiles/server1/cfg_sourcemod/">cfg_sourcemod</a>  ->  /L4D2/left4dead2/cfg/sourcemod (all the plugins' config files)
    │       │   ├── <a href="versatile-l4d2-docker/tree/main/org/my-org/profiles/server1/server.cfg">server.cfg</a>     ->  /L4D2/left4dead2/cfg/server.cfg
    │       │   └── <a href="versatile-l4d2-docker/tree/main/org/my-org/profiles/server1/sourcemod/">sourcemod</a>
    │       │       ├── data              ->  /L4D2/left4dead2/addons/sourcemod/data
    │       │       ├── gamedata          ->  /L4D2/left4dead2/addons/sourcemod/gamedata
    │       │       ├── logs              ->  /L4D2/left4dead2/addons/sourcemod/logs
    │       │       ├── plugins_custom    ->  /L4D2/left4dead2/addons/sourcemod/plugins/custom
    │       │       └── translations      ->  /L4D2/left4dead2/addons/sourcemod/translations
    │       └── server2 (etc.)
    └── my-friends-org (etc.)
</code>
</pre>

# Setup

## Prerequisites
Zeroth, ensure docker is installed on your server.

Some guides: [docs.docker.com](https://docs.docker.com/engine/install/), [CN/中国用户](https://cloud.tencent.com/developer/article/1005133)

## Get the game
Clone this repo to your server:

```
git clone https://github.com/yxnan/versatile-l4d2-docker.git ~/l4d2
cd ~/l4d2
```

Run the following command to download the game to `game/` directory:

```
run/update-game.sh
```

It spawns steamcmd in a detached docker instance so you can move on and checks later.

## Build the game runner

It's highly advised to run the game container as the same user id as host's,
as it solves many permission-related issues. So we are building our own image
instead of using a pre-built one.

```
build/build.sh
```

Or you can check `build/build.sh` for more customizable build args
before running the above command. It's safe to skip them, as we can override them
later in the docker-compose file.

## Customize your orgs and profiles

This repo has 1 example org called `my-org`, with its `docker-compose-myorg.yml` file:

```yaml
services:
  server1:
    image: yxnan/l4d2-runner:latest
    ...
  server2:
    image: yxnan/l4d2-runner:latest
    ...
  vpk_trimmer:
    image: yxnan/l4d2-vpk-trimmer:latest
    profiles:
      - optional
    ...
```

It spawns 2 profiles, namely `server1` and `server2`, you can populate the directory
as stated in the [hierarchy graph](#Brief), or make up your own structures altogether.

Here is a common modded-server setup:

0. (Config profile)  Edit the docker compose file for profile settings, like name, port, map etc.
1. (Install mods)    Get sourcemod, metamod, etc., extract them to `org/my-org/comm/addons`
2. (Shared cfg)      Edit `org/my-org/comm/cfg_comm/comm.cfg` to add your steam group, server region, etc.
3. (Specific cfg)    Edit `org/my-org/profiles/server1/server.cfg` to set the hostname, etc.
4. (Install Plugins) Get your plugins, install them to `org/my-org/profiles/server1/sourcemod`

Voilà! You can start your server by `docker compose -f run/docker-compose-myorg.yml up -d`

Optionally, if you want to utilise the `vpk-trimmer`,
you can pass additional args `--profile optional` to docker compose.
See more about [yxnan/l4d2-vpk-trimmer](https://github.com/yxnan/l4d2-vpk-trimmer)
and [upload/README.txt](org/my-org/upload/).

Create a new org is needed when your friends also want to host their server
on your machine, and they prefer a vastly different setup from yours, so you can't
reasonably share any common configs from your org. It's easy to do so, just create a
separate org and docker-compose file for them. They can even use their own
hierarchy different than yours.

# Custom hierarchy

**Beware** that in the above step 1, you need to also keep an original copy of the sourcemod's
`gamedata` and `translations`, and copy them into profile's sourcemod directory
everytime you create a new profile, as they are managed by profiles instead of org,
because docker doesn't provide a convenient way to `merge` two bind-mounts of
the same destination. Essentially what we want here is a shared `translations`,
which holds the translation files of default plugins set and also a profile-specific `translations`,
which `inherit` org's `translations` while have its custom plugins' translations files.
Unfortunately it can't be achieved easily in docker. You can try overlay-fs but I just stopped here.

Remember you can ditch this hierarchy and use a simpler one to avoid these headaches,
like having a separate `sourcemod` installation for each profile.
I came up with the current one just because I want to share a common set of
plugins across my org, and also some nice storage-space deduplication.

Interestingly we can have a shared `plugins` and a profile-specific one,
because unlike the other directories,
sourcemod will recursively find every smx files under `plugins` and load them,
so this enables us to create separate subdirectory for our profile-specific plugins.
See more in [org-sourcemod](org/my-org/comm/addons/sourcemod/)
and [profile-sourcemod](org/my-org/profiles/server1/sourcemod/).


# Todos

1. Add a docker service for cleaning `downloads` routinely.
Close [downloads/README.txt](org/my-org/comm/downloads/)
2. Add a `backup-org.sh` script.
