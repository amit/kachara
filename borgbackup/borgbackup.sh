#!/bin/bash
# https://borgbackup.readthedocs.io/en/stable/quickstart.html#a-step-by-step-example
export MYHOSTNAME='client.example.com'
export MYSERVERNAME='server.example.com'
# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO="ssh://borgbak@${MYSERVERNAME}:20022/backups/${MYHOSTNAME}"
# Can use `openssl rand -base64 48` to generate the following
export BORG_PASSPHRASE='XXXXXXXXXXXXXXXXX'
export BORG_RSH='ssh -oBatchMode=yes'
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM
cd `dirname "$0"`

info "Starting backup on `hostname -A`"
# Create ssh-agent for logging in
eval `ssh-agent`
ssh-add -t 1h "${MYHOSTNAME}_backup" 2>/dev/null
# Backup the most important directories into an archive named after
# the machine this script is currently running on:

borg create                         \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
    --exclude '/home/*/.cache/*'    \
    --exclude '/var/cache/*'        \
    --exclude '/var/tmp/*'          \
                                    \
    ::"${MYHOSTNAME}-{now}"            \
    /etc                            \
    /home                            \
    /var                            \
    /root

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                          \
    --list                          \
    --prefix "${MYHOSTNAME}-"          \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6               \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 1 ];
then
    info "Backup and/or Prune finished with a warning"
fi

if [ ${global_exit} -gt 1 ];
then
    info "Backup and/or Prune finished with an error"
fi

# Kill ssh-agent
kill ${SSH_AGENT_PID}

exit ${global_exit}

