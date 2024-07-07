{ config, pkgs, ... }:
{
  environment.systemPackages = [
    (
      let
        # XXX specify the postgresql package you'd like to upgrade to.
        # Do not forget to list the extensions you need.
        newPostgres = pkgs.postgresql_14.withPackages (pp: [
          # pp.plv8
        ]);
      in
      pkgs.writeScriptBin "upgrade-pg-cluster" ''
        #!/usr/bin/env bash
        set -eux
        # XXX it's perhaps advisable to stop all services that depend on postgresql
        systemctl stop postgresql \
          gitlab.service \
          gitlab-workhorse.service \
          gitlab-sidekiq.service \
          gitlab-postgresql.service \
          gitlab-db-config.service \
          gitlab-config.service

        export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"

        export NEWBIN="${newPostgres}/bin"

        export OLDDATA="${config.services.postgresql.dataDir}"
        export OLDBIN="${config.services.postgresql.package}/bin"

        # install otherwise comes from gitlab-shell
        ${pkgs.coreutils}/bin/install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        #mkdir -m 0700 "$NEWDATA"
        #chown postgres:postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

        sudo -u postgres $NEWBIN/pg_upgrade \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir $OLDBIN --new-bindir $NEWBIN \
          "$@"
      ''
    )
  ];
}
