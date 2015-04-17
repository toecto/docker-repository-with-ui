# Private docker registry with UI and read/write access
================================

## Split access read only and admin users
### Uses docker-compose to run images: nginx, registry, konradkleine/docker-registry-frontend


## Install and run

```bash
git clone https://github.com/toecto/docker-repository.git
cd docker-repository

# Install certificates
# See cetifacated configuration for more details
cp $(pwd)/builtin-apps/registry-frontend/security/ca.pem /usr/local/share/ca-certificates/project-ca.crt
update-ca-certificates
service docker restart


#runnig repo
docker-compose up

docker login localhost:5000
[admin]
[admin]

docker push localhost:5000/ubuntu # assuming you have it
docker pull localhost:5000/ubuntu # assuming you have it

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

###Defaut users
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
