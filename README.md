# Gitosis in Docker

If you have a legacy [gitosis](https://github.com/tv42/gitosis) install going that is becoming harder and harder to maintain, this is for you. This runs gitosis in a container that you can map to a legacy gitosis directory.

## Build

```bash
# Copy your public ssh key to the current directory
cp ~/.ssh/id_rsa.pub .

# In the below command, set USER to either gitosis or git,
# depending on whether you want to clone is git@ or gitosis@
# The default is gitosis.

# Also, we set HOST_UID and HOST_GID to make sure that both the host
# and the container have the same uid/gid for user gitosis; otherwise
# the docker container cannot read/write the mapped directory
docker build --build-arg USER=gitosis --build-arg HOST_UID=`id -u gitosis` --build-arg HOST_GID=`id -g gitosis`  -t gitosis .
```

## Run

```bash
# Your public IP, try to guess it from eth0
IP=`ip a s eth0 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2 | head -1`

# Public port where you want gitosis to be available
PORT=8222

# runs the gitosis image, while mounting the legacy /srv/gitosis directory and makes it accessible
docker run --mount type=bind,source=/srv/gitosis,target=/srv/gitosis -p $IP:$PORT:22 -it gitosis:latest

# is now accessible... assumes USER was set to gitosis earlier; otherwise use git@
git clone gitosis@${IP}:${PORT}/gitosis-admin
```

## Run in the background

```bash
docker run -d --mount type=bind,source=/srv/gitosis,target=/srv/gitosis -p ${IP}:${PORT}:22 gitosis:latest
```

## Modify `.ssh/config`

You'll likely need something like this in your `~/.ssh/config`

```
Host git.yourserver.com
  User gitosis # ...or git if that's what you used earlier
  Port 8222 # or whatever port you are making available
```

