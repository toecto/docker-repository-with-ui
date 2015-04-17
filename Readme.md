# Private docker registry with UI and read/write access
================================


Main features:
* SSL secured
* Basic authentification with split access - read only or admin users.
* Web interface

Uses public images: registry, konradkleine/docker-registry-frontend

Requirements:
* docker
* docker-compose

## Install and run

```bash
git clone https://github.com/toecto/docker-repository.git
cd docker-repository

##IF you want create your own certificates
rm builtin-apps/registry-frontend/security/*.pem
./create-certificats.sh localhost #put your domain

# Install certificates on ALL docker client hosts
# See cetifacated configuration for more details
cp $(pwd)/builtin-apps/registry-frontend/security/ca.pem /usr/local/share/ca-certificates/project-ca.crt
update-ca-certificates
service docker restart

#run repo
docker-compose up -d

docker login localhost:5000
[admin]
[admin]

docker push localhost:5000/ubuntu # assuming you have it
docker pull localhost:5000/ubuntu

```

Open UI in a browser: `https://localhost:5080`


## Configure

Storage: `/var/docker-registry` Can be changed in docker-compose.yml

See docker registry [documentation](https://github.com/docker/docker-registry) for more details.

Read/Write access handled by nginx. Usernames started with `admin-` or just `admin` can change



## Users

`builtin-apps/registry-frontend/security/registry.htpasswd`

Usernames started with `admin-` or just `admin` have access to modify registry.
Push images, create, remove tags.

Any other useers can only read registry.

###Default users
admin:admin

readonly:readonly

###Create users

```bash
cd builtin-apps/registry-frontend/security/

# Creates new file

htpasswd -c registry.htpasswd admin
# Adds user
htpasswd registry.htpasswd someuser
```


## Certificates

Default certificats are configured to work at localhost. All passwords are `admin`

You can create your CA and sign repository cert using:

```bash
# Remove existing certs first
rm builtin-apps/registry-frontend/security/*.pem
./create-certificats.sh your.domain.name
```

Register ca.pem sertificate at docker-repository client host:

```bash
cp $(pwd)/ca.pem /usr/local/share/ca-certificates/project-ca.crt
update-ca-certificates
service docker restart
```

