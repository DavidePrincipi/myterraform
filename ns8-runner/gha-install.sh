#!/bin/bash

#
# Download, configure, register, and start the actions-runner service
#

set -e

read -s -r -p repo:  github_repo
read -s -r -p user:  github_user
read -s -r -p token: github_token

INSTALL_DIR=~/.local/actions-runner
distro=$( ( source /etc/os-release ; printf %s $ID ; ) )

echo "Install actions-runner on ${distro} (${INSTALL_DIR}):"

mkdir -vp ${INSTALL_DIR}

cd ${INSTALL_DIR}
curl -O -L https://github.com/actions/runner/releases/download/v2.280.0/actions-runner-linux-x64-2.280.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.280.0.tar.gz
sudo ./bin/installdependencies.sh

echo "Runner registration:"

REGISTRATION_TOKEN=$(curl -u ${github_user}:${github_token} -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${github_repo}/actions/runners/registration-token | jq -r '.token')
./config.sh --work ~/_work --url https://github.com/${github_repo} --token ${REGISTRATION_TOKEN} --labels ns8-runner,${distro} --unattended --replace

echo "Install Systemd unit:"

sd_units_dir=~/.config/systemd/user
mkdir -pv ${sd_units_dir}/default.target.wants/

cat - <<EOF >${sd_units_dir}/actions-runner.service
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
ExecStart=bash ${INSTALL_DIR}/bin/runsvc.sh
WorkingDirectory=${INSTALL_DIR}
KillMode=process
KillSignal=SIGTERM
TimeoutStopSec=5min

[Install]
WantedBy=default.target
EOF

ln -vs ${sd_units_dir}/actions-runner.service ${sd_units_dir}/default.target.wants/actions-runner.service
