tempfile=$(mktemp)

if [ ( ! -f /etc/docker/daemon.json ) -o -z "$(cat /etc/docker/daemon.json)" ]; then
  echo '{ "iptables": false }' >$tempfile
else
  jq '. + { "iptables": false }' /etc/docker/daemon.json >$tempfile
fi
chmod --reference=/etc/docker/daemon.json $tempfile
chown --reference=/etc/docker/daemon.json $tempfile
mv $tempfile /etc/docker/daemon.json

BASE_DIR=$(dirname $0)
OLD_DIR=$(pwd)

cd $BASE_DIR

find etc -type f -exec install -Dm 0644 -g0 -o0 --backup=t '{}' '/{}' \;

cd $OLD_DIR
