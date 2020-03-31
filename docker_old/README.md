# Build mariadb into docker containers

## Create docker containers

```bash
docker build . -f dockerfile/debian9-packaging -t debian9-packaging
docker build . -f dockerfile/debian10-packaging -t debian10-packaging
docker build . -f dockerfile/sid-packaging -t sid-packaging

docker run -i -v mariadb_data:/data -t debian9-packaging /bin/bash
docker run -i -v mariadb_data:/data -t debian10-packaging /bin/bash
docker run -i -v mariadb_data:/data -t sid-packaging /bin/bash
```

## Clone repo to workdir

- get git and clone etc to /data/build

```bash
cd /home/faust/MariaDB/upstream.git
git co <branch>
sudo git checkout-index --prefix=/home/faust/MariaDB/mariadb_data/\_data/build/ -a
```

- or

```bash
sudo git clone --branch 10.1-MDEV-15869 /home/faust/MariaDB/upstream \
 /home/faust/MariaDB/mariadb_data/build
```

### upstream

```bash
apt update
cd /data/build
git clean -fdx && git reset --hard
mk-build-deps -t 'apt-get -y -o Debug::pkgProblemResolver=yes --no-install-recommends' debian/control -i
time env DEB_BUILD_OPTIONS="parallel=6 nocheck" debian/autobake-deb.sh;
```

### salsa

<https://salsa.debian.org/mariadb-team/mariadb-10.3/raw/master/debian/README.Contributor>

```bash
cd /data
gbp clone --pristine-tar https://salsa.debian.org/faust-guest/mariadb-10.3
cd mariadb-10.3
mk-build-deps -r -i debian/control -t "apt-get -y -o Debug::pkgProblemResolver=yes --no-install-recommends"
git clean -fdx && git reset --hard
time env DEB_BUILD_OPTIONS="parallel=6 nocheck" gbp buildpackage
```

## Test installation into docker systemd

```bash
docker build . -f dockerfile/systemd-debian9 -t systemd-debian9
docker run --detach --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v mariadb_data:/data -t systemd-debian9
docker exec -it [container_id] /bin/bash
cd /data
apt update
apt install ./mariadb-server-10.1_10.1.38+maria-1~stretch_amd64.deb ./mariadb-server-core-10.1_10.1.38+maria-1~stretch_amd64.deb
```

## CI salsa

```bash
gbp pull
gbp push
git co master
git ru
git rebase upstream/master
git push
git co branche
git push
```

## from <https://wiki.debian.org/UsingUpstreamGit>

```bash
git pull upstream master --tags
```

## Test into a systemd container

```bash
docker build . -f dockerfile/systemd-debian10 -t systemd-debian10
docker run --detach --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v mariadb*data:/data -t systemd-debian10
docker exec -it [container_id] /bin/bash
cd /data
apt update
apt install ./mariadb-server-10.3*\_.deb ./mariadb-server-core-10.3\_\_.deb
```
