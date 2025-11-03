# This is a good source for a Ceph dealio
# https://gist.github.com0/nh2/13425a1f18b4c1ce82edb63c10b163c9
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.ceph-benaco;
  commaSep = builtins.concatStringsSep ",";

  ensureUnitExists =
    c': name:
    let
    in
    #unitName = (builtins.elemAt (builtins.split "\\." name) 0);
    if c'.systemd.services ? unitName then name else name; # "Unable to locate ${name} at ${commaSep (builtins.attrNames c')}";
in

{

  ###### interface

  options = {

    services.ceph-benaco = {

      enable = mkEnableOption "Ceph distributed filesystem";

      package = mkOption {
        type = types.package;
        default = pkgs.ceph;
        defaultText = literalExpression "pkgs.ceph-benaco";
        description = "Ceph package to use.";
      };

      fsid = mkOption {
        type = types.str;
        description = "Unique cluster identifier.";
      };

      clusterName = mkOption {
        type = types.str;
        description = "Cluster name.";
        default = "ceph";
      };

      initialMonitors = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              hostname = mkOption {
                type = types.str;
                description = "Initial monitor hostname.";
              };

              ipAddress = mkOption {
                type = types.str;
                description = "Initial monitor IP address.";
              };
            };
          }
        );
        description = "Initial monitors.";
      };

      mdsNodes = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              hostname = mkOption {
                type = types.str;
                description = "MDS hostname.";
              };

              ipAddress = mkOption {
                type = types.str;
                description = "MDS IP address.";
              };
            };
          }
        );
        description = "MDS nodes.";
      };

      publicNetworks = mkOption {
        type = types.listOf types.str;
        description = "Public network(s) of the cluster.";
      };

      clusterNetworks = mkOption {
        type = types.listOf types.str;
        description = "Cluster backend networks for OSD sync";
      };

      adminKeyring = mkOption {
        type = types.path;
        description = "Ceph admin keyring to install on the machine.";
      };

      monitor = {
        enable = mkEnableOption "Activate a Ceph monitor on this machine.";

        initialKeyring = mkOption {
          type = types.path;
          description = "Keyring file to use when initializing a new monitor";
          example = "/path/to/ceph.mon.keyring";
        };

        nodeName = mkOption {
          type = types.str;
          description = "Ceph monitor node name.";
          example = "node1";
        };

        bindAddr = mkOption {
          type = types.str;
          description = "IP address that the OSDs shall bind to.";
          example = "10.0.0.1";
        };

        advertisedPublicAddr = mkOption {
          type = types.str;
          description = "IP address that the monitor shall advertise.";
          example = "10.0.0.1";
        };
      };

      manager = {
        enable = mkEnableOption "Activate a Ceph manager on this machine.";

        nodeName = mkOption {
          type = types.str;
          description = "Ceph manager node name.";
          example = "node1";
        };
      };

      osdBindAddr = mkOption {
        type = types.str;
        description = "IP address that the OSDs shall bind to.";
        example = "10.0.0.1";
      };

      osdAdvertisedPublicAddr = mkOption {
        type = types.str;
        description = "IP address that the OSDs shall advertise.";
        example = "10.0.0.1";
      };

      osds = mkOption {
        default = { };
        example = {
          osd1 = {
            enable = true;
            bootstrapKeyring = "/path/to/ceph.client.bootstrap-osd.keyring";
            id = 1;
            uuid = "11111111-1111-1111-1111-111111111111";
            blockDevice = "/dev/sdb";
            blockDeviceUdevRuleMatcher = ''KERNEL=="sdb"'';
            clusterAddress = "10.1.0.1";
          };
          osd2 = {
            enable = true;
            bootstrapKeyring = "/path/to/ceph.client.bootstrap-osd.keyring";
            id = 2;
            uuid = "22222222-2222-2222-2222-222222222222";
            blockDevice = "/dev/sdc";
            blockDeviceUdevRuleMatcher = ''KERNEL=="sdc"'';
            clusterAddress = "10.1.0.2";
          };
        };
        description = ''
          This option allows you to define multiple Ceph OSDs.
          A common idiom is to use one OSD per physical hard drive.

          Note that the OSD names given as attributes of this key
          are NOT what ceph calls OSD IDs (instead, those are defined
          by the 'services.ceph-benaco.osds.*.id' fields).
          Instead, the name is an identifier local and unique to the
          current machine only, used only to name the systemd service
          for that OSD.
        '';
        type = types.attrsOf (
          types.submodule {
            options = {

              enable = mkEnableOption "Activate a Ceph OSD on this machine.";

              bootstrapKeyring = mkOption {
                type = types.path;
                description = "Ceph OSD bootstrap keyring.";
                example = "/path/to/ceph.client.bootstrap-osd.keyring";
              };

              id = mkOption {
                type = types.int;
                description = "The ID of this OSD. Must be unique in the Ceph cluster.";
                example = 1;
              };

              uuid = mkOption {
                type = types.str;
                description = "The UUID of this OSD. Must be unique in the Ceph cluster.";
                example = "abcdef12-abcd-1234-abcd-1234567890ab";
              };

              systemdExtraRequiresAfter = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = ''
                  Add the specified systemd units to the "requires" and "after"
                  lists of the systemd service of this OSD.

                  Useful, for example, to decrypt the underlying block devices with LUKS first.

                  NixOS modules allow override those lists from outside, but for that
                  the names of the systemd services for the OSDs need to be known;
                  this option is a convenience to not have to know them from outside.
                '';
                example = "decrypt-my-disk.service";
              };

              skipZap = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  Whether to skip the zapping of the the OSD device on initial OSD
                  installation.

                  Skipping is needed because <command>ceph-volume</command> cannot
                  zap device-mapper devices:
                  <link xlink:href="https://tracker.ceph.com/issues/24504" />

                  In that case you need to wipe the device manually.

                  In the common case of placing the OSD on a cryptsetup LUKS device
                  (which is a device-mapper device), re-creating the encryption
                  from scratch with a new key zaps anything anyway, in which case
                  zapping can be skipped here.
                '';
              };

              blockDevice = mkOption {
                type = types.str;
                description = "The block device used to store the OSD.";
                example = "/dev/sdb";
              };

              blockDeviceUdevRuleMatcher = mkOption {
                type = types.str;
                description = ''
                  An udev rule matcher matching the block device used to store the OSD.
                  Will be spliced into the udev rule that is
                  used to set access permissions to the ceph user via an udev rule.

                  This is a matcher instead of just a device name to allow flexibility:
                  Normal disks can be easily matched with <code>KERNEL=="sda1"</code>, but
                  device-mapper may not; for example, decrypted cryptsetup LUKS devices
                  have a less useful <code>KERNEL=="dm-4"</code> and may better be matched
                  using <code>ENV{DM_NAME}=="mydisk-decrypted"</code>.
                '';
                example = ''KERNEL=="sdb"'';
              };

              dbBlockDevice = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  The block device used to store the OSD's BlueStore DB device.

                  Put this on a faster device than <option>blockDevice</option> to improve performance.

                  See <link xlink:href="http://docs.ceph.com/docs/master/rados/configuration/bluestore-config-ref/" />
                  for details.
                '';
                example = "/dev/sdc";
              };

              dbBlockDeviceUdevRuleMatcher = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  Like <option>blockDeviceUdevRuleMatcher</option> but for the
                  <option>dbBlockDevice</option>.
                '';
                example = ''KERNEL=="sdc"'';
              };

              clusterAddress = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  The IP address on the dedicated cluster network that
                  is used by the backend communication for OSD communication.
                '';
                example = "10.1.0.1f";
              };

            };
          }
        );
      };

      mds = {
        enable = mkEnableOption "Activate a Ceph MDS on this machine.";

        nodeName = mkOption {
          type = types.str;
          description = "Ceph MDS node name.";
          example = "node1";
        };

        listenAddr = mkOption {
          type = types.str;
          description = "IP address that the MDS shall advertise.";
          example = "10.0.0.1";
        };
      };

      extraConfig = mkOption {
        type = types.str;
        default = "";
        description = ''
          Additional ceph.conf settings.

          See the sample file for inspiration:
          <link xlink:href="https://github.com/ceph/ceph/blob/master/src/sample.ceph.conf" />
        '';
      };
    };
  };

  ###### implementation

  config =
    let
      monDir = "/var/lib/ceph/mon/${cfg.clusterName}-${cfg.monitor.nodeName}";
      mgrDir = "/var/lib/ceph/mgr/${cfg.clusterName}-${cfg.manager.nodeName}";
      mdsDir = "/var/lib/ceph/mds/${cfg.clusterName}-${cfg.mds.nodeName}";

      # File permissions for things that are on locations wiped at start
      # (e.g. /run or its /var/run symlink).
      ensureTransientCephDirs = ''
        install -m 770 -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} -d /var/run/ceph
      '';

      # File permissions from cluster deployed with ceph-deploy.
      ensureCephDirs = ''
        install -m 3770 -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} -d /var/log/ceph
        install -m 770 -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} -d /var/run/ceph
        install -m 750 -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} -d /var/lib/ceph
        install -m 755 -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} -d /var/lib/ceph/mon
        install -m 755 -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} -d /var/lib/ceph/mgr
        install -m 755 -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} -d /var/lib/ceph/osd
      '';

      # Utilities called by Ceph device health scraping, see:
      # https://docs.ceph.com/en/latest/rados/operations/devices/#enabling-monitoring
      # As per https://github.com/ceph/ceph-container/pull/1490/commits/c49e821599965ae92a88b2c78077ee03c4405895,
      # both the OSDs and the `mon` need this.
      # Ceph calls these utilities with `sudo`. That requires sudoers entries.
      # Sudoers entries require absolute path; that exact (nix store) path needs to
      # be used by Ceph, so it needs to be given to the systemd unit via `path`.
      # This is why we pair each `sudoersExtraRule` with the `package` to put onto
      # that `path`.
      #
      # Entries are based on:
      # https://github.com/ceph/ceph/blob/a2f5a3c1dbfa4dce41e25da4f029a8fdb8c8d864/sudoers.d/ceph-smartctl
      cephMonitoringSudoersCommandsAndPackages = [
        {
          package = pkgs.smartmontools;
          sudoersExtraRule = {
            # entry for `security.sudo.extraRules`
            users = [ config.users.users.ceph.name ];
            commands = [
              {
                command = "${lib.getBin pkgs.smartmontools}/bin/smartctl -x --json=o /dev/*";
                options = [ "NOPASSWD" ];
              }
            ];
          };
        }
        {
          package = pkgs.nvme-cli;
          sudoersExtraRule = {
            # entry for `security.sudo.extraRules`
            users = [ config.users.users.ceph.name ];
            commands = [
              {
                command = "${lib.getBin pkgs.nvme-cli}/bin/nvme * smart-log-add --json /dev/*";
                options = [ "NOPASSWD" ];
              }
            ];
          };
        }
      ];

      cephDeviceHealthMonitoringPathsOrPackages =
        with pkgs;
        [
          # Contains `sudo`. Ceph wraps this around the other health check programs.
          # Cannot use `pkgs.sudo` because that one is not SUID, see:
          # https://discourse.nixos.org/t/sudo-uid-issues/9133
          "/run/wrappers" # `systemd.services.<name>.path` adds the `bin/` subdir of this
        ]
        ++ map ({ package, ... }: package) cephMonitoringSudoersCommandsAndPackages;

      # Unused localOsdServiceName in the following line
      # deadnix: skip
      makeCephOsdSetupSystemdService =
        _localOsdServiceName: osdConfig:
        let
          osdExistenceFile = "/var/lib/ceph/osd/.${toString osdConfig.id}.${osdConfig.uuid}.nix-existence";
        in
        mkIf osdConfig.enable {
          description = "Initialize Ceph OSD";

          requires = osdConfig.systemdExtraRequiresAfter;
          after = osdConfig.systemdExtraRequiresAfter;

          path = with pkgs; [
            # The following are currently missing in Ceph's wrapping, see https://github.com/NixOS/nixpkgs/issues/147801#issue-1065600852
            util-linux # for `lsblk`
            lvm2 # for `lvs`
          ];

          # TODO Use `udevadm trigger --settle` instead of the separate `udevadm settle`
          #      once that feature is available to us with systemd >= 238;
          #      see https://github.com/systemd/systemd/commit/792cc203a67edb201073351f5c766fce3d5eab45
          preStart = ''
            set -x
            ${ensureCephDirs}
            install -m 755 -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} -d /var/lib/ceph/bootstrap-osd
            # `install` is not atomic, see
            # https://lists.gnu.org/archive/html/bug-coreutils/2010-02/msg00243.html
            # so use `mktemp` + `mv` to make it atomic.
            TMPFILE=$(mktemp --tmpdir=/var/lib/ceph/bootstrap-osd/)
            install -o ${config.users.users.ceph.name} -g ${config.users.groups.ceph.name} ${osdConfig.bootstrapKeyring} "$TMPFILE"
            mv "$TMPFILE" /var/lib/ceph/bootstrap-osd/ceph.keyring

            # Trigger udev rules for permissions of block devices and wait for them to settle.
            udevadm trigger --name-match=${osdConfig.blockDevice}
          ''
          + lib.optionalString (osdConfig.dbBlockDevice != null) ''
            udevadm trigger --name-match=${osdConfig.dbBlockDevice}
          ''
          + ''
            udevadm settle
          ''
          + (optionalString (!osdConfig.skipZap) (
            ''
              # Zap OSD block devices, otherwise `ceph-osd` below will try to fsck if there's some old
              # ceph data on the block device (see https://tracker.ceph.com/issues/24099).
              ${cfg.package}/bin/ceph-volume lvm zap ${osdConfig.blockDevice}
            ''
            + lib.optionalString (osdConfig.dbBlockDevice != null) ''
              ${cfg.package}/bin/ceph-volume lvm zap ${osdConfig.dbBlockDevice}
            ''
          ));

          script = ''
            set -euo pipefail
            set -x
            until [ -f /etc/ceph/${cfg.clusterName}.client.admin.keyring ]
            do
              sleep 1
            done

            OSD_SECRET=$(${cfg.package}/bin/ceph-authtool --gen-print-key)
            echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | \
              ${cfg.package}/bin/ceph --cluster ${cfg.clusterName} osd new ${osdConfig.uuid} ${toString osdConfig.id} -i - \
              -n client.bootstrap-osd -k ${osdConfig.bootstrapKeyring}
            mkdir -p /var/lib/ceph/osd/${cfg.clusterName}-${toString osdConfig.id}

            ln -s ${osdConfig.blockDevice} /var/lib/ceph/osd/${cfg.clusterName}-${toString osdConfig.id}/block
          ''
          + lib.optionalString (osdConfig.dbBlockDevice != null) ''
            ln -s ${osdConfig.dbBlockDevice} /var/lib/ceph/osd/${cfg.clusterName}-${toString osdConfig.id}/block.db
          ''
          + ''

            ${cfg.package}/bin/ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-${toString osdConfig.id}/keyring \
              --name osd.${toString osdConfig.id} --add-key $OSD_SECRET

            ${cfg.package}/bin/ceph-osd -i ${toString osdConfig.id} --mkfs --osd-uuid ${osdConfig.uuid} --setuser ${config.users.users.ceph.name} --setgroup ${config.users.groups.ceph.name} --osd-objectstore bluestore
            touch ${osdExistenceFile}
          '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            PermissionsStartOnly = true; # only run the script as ceph, preStart as root
            User = config.users.users.ceph.name;
            Group = config.users.groups.ceph.name;
          };
          unitConfig = {
            ConditionPathExists = "!${osdExistenceFile}";
          };
        };

      makeCephOsdSystemdService =
        localOsdServiceName: osdConfig:
        mkIf osdConfig.enable {
          description = "Ceph OSD";

          # Note we do not have to add `osdConfig.systemdExtraRequiresAfter` here because
          # that's already a dependency of our dependency `ceph-osd-setup-*`.
          requires = [ (ensureUnitExists config "ceph-osd-setup-${localOsdServiceName}.service") ];
          requiredBy = [ "multi-user.target" ];
          after = [
            "network.target"
            "local-fs.target"
            "time-sync.target"
            (ensureUnitExists config "ceph-osd-setup-${localOsdServiceName}.service")
          ];
          wants = [
            "network.target"
            "local-fs.target"
            "time-sync.target"
          ];

          path = [
            # TODO: use wrapProgram in the ceph package for this in the future
            pkgs.getopt
          ]
          ++ cephDeviceHealthMonitoringPathsOrPackages;

          restartTriggers = [ config.environment.etc."ceph/${cfg.clusterName}.conf".source ];

          preStart = ''
            ${ensureTransientCephDirs}
            ${lib.getLib cfg.package}/libexec/ceph/ceph-osd-prestart.sh --cluster ${cfg.clusterName} --id ${toString osdConfig.id}
          '';

          serviceConfig =
            let
              clusterIpArg = lib.optionalString (
                osdConfig.clusterAddress != null
              ) "--cluster_addr=${osdConfig.clusterAddress}";
            in
            {
              LimitNOFILE = "1048576";
              LimitNPROC = "1048576";

              ExecStart = ''
                ${cfg.package}/bin/ceph-osd -f --cluster ${cfg.clusterName} --id ${toString osdConfig.id} --setuser ${config.users.users.ceph.name} --setgroup ${config.users.groups.ceph.name} "--public_bind_addr=${cfg.osdBindAddr}" "--public_addr=${cfg.osdAdvertisedPublicAddr}" "${clusterIpArg}"
              '';
              ExecReload = ''
                ${pkgs.coreutils}/bin/kill -HUP $MAINPID
              '';
              Restart = "on-failure";
              ProtectHome = "true";
              ProtectSystem = "full";
              PrivateTmp = "true";
              TasksMax = "infinity";
              # StartLimitBurst="3";
            };
          # startLimitIntervalSec = 30 * 60;
        };

    in
    mkIf cfg.enable {
      environment.systemPackages = [ cfg.package ];

      networking.firewall = {
        allowedTCPPorts = [
          # Ceph outside of VPN because it is very data heavy and causes packet loss.
          # We enable msgr-v2 only because that allows its own on-wire encryption.
          3300 # ceph msgr-v2
        ];
        allowedTCPPortRanges = [
          {
            from = 6800;
            to = 7300;
          } # https://docs.ceph.com/en/pacific/rados/configuration/network-config-ref/
        ];
      };

      # Reminder of how `ceph.conf` works:
      #
      # * Ceph upstream docs now recommend to use underscores instead of spaces.
      # * Options in more specific sections like `[mon]` override those in less
      #   specific sections like `[global]`. But all options can be written into all sections,
      #   and an option has the same name, no matter in which section it is written.
      #   Thus, put options in `[global]`, and only use a diffent section
      #   if you want to override an option you've set in `global`.
      #
      # Sample: https://github.com/ceph/ceph/blob/master/src/sample.ceph.conf
      environment.etc."ceph/${cfg.clusterName}.conf".text = ''
        [global]
        fsid = ${cfg.fsid}
        mon_initial_members = ${commaSep (map (mon: mon.hostname) cfg.initialMonitors)}
        mon_host = ${commaSep (map (mon: mon.ipAddress) cfg.initialMonitors)}

        # Ceph clusters go into WARN health mode, until
        # the following setting is made strict by setting it to `false`:
        # See: https://docs.ceph.com/en/latest/security/CVE-2021-20288/#recommendations
        # As of writing, this setting is not documented outside of the CVE note :(
        #
        # While for new clusters the warning no longer seems to appear, it still
        # appears in our existing clusters unless this option is set, see:
        # https://tracker.ceph.com/issues/53751#note-7
        auth_allow_insecure_global_id_reclaim = false

        # Disable dirfrag prefetch on MDS restart to prevent out-of-memory after
        # many files were opened.
        # Note this option has no effect on Ceph < 15, because it doesn't exist there.
        # TODO: Remove this once we're on a Ceph version that includes this default,
        #       see https://github.com/ceph/ceph/pull/44667.
        #       This is assuming that the commit fixes existing clusters, see
        #       https://github.com/ceph/ceph/pull/44667#issuecomment-1036103397
        #       If it doesn't this can only be removed once we have no existing
        #       cluster with the old default.
        mds_oft_prefetch_dirfrags = false

        # Disable sleep between HDD recovery operations, otherwise recovery
        # will take forever when small objects (e.g. CephFS files) are on HDD.
        # See https://tracker.ceph.com/issues/23595#note-12
        osd_recovery_sleep_hdd = 0.0

        # Increase scrub intervals by 4x.
        # Since we store many small files on HDD, and scrubbing apparently
        # iterates over all objects
        # we have no chance to scrub at the default intervals.
        #
        # (This was written when we had 400M files across 30 HDDs.)
        # Change this back once we have reduced our number of files per disk.
        osd_scrub_min_interval = 345600
        osd_scrub_max_interval = 2419200
        osd_deep_scrub_interval = 2419200

        public_network = ${commaSep cfg.publicNetworks}
        cluster_network = ${commaSep cfg.clusterNetworks}
        auth_cluster_required = cephx
        auth_service_required = cephx
        auth_client_required = cephx

        # Enforce on-wire transport encryption.
        ms_cluster_mode = secure
        ms_service_mode = secure
        ms_client_mode = secure

        ${cfg.extraConfig}
      '';

      environment.etc."ceph/${cfg.clusterName}.client.admin.keyring" = {
        source = cfg.adminKeyring;
        mode = "0600";
        # Make ceph own this keyring so that it can use it to get keys for its daemons.
        user = "ceph";
        group = "ceph";
      };

      users.users.ceph = {
        isNormalUser = false;
        isSystemUser = true;
        # TODO: Legacy UID / GID chosen from before we configured the UID declaratively.
        #       In the future, we whould change this whole module to use
        #       `config.ids.uids.ceph`, like the upstream nixpkgs Ceph module does.
        #       Switching away from `nogroup` would also be good as described there.
        #       For both cases, we'll have to `chown` all relevant existing files on
        #       deployments, such as `/var/lib/ceph`, and log files.
        uid = 1001;
        group = config.users.groups.nogroup.name;
      };
      users.groups.ceph = {
        # TODO: Same TODO as above for the `uid`.
        gid = 499;
      };

      # Allow ceph daemons (which run as user ceph) to collect device health metrics.
      security.sudo.extraRules = map (
        { sudoersExtraRule, ... }: sudoersExtraRule
      ) cephMonitoringSudoersCommandsAndPackages;

      # The udevadm trigger/settle in `makeCephOsdSetupSystemdService` waits for these rules rule to be applied.
      services.udev.extraRules = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          _localOsdServiceName: osdConfig:
          ''
            SUBSYSTEM=="block", ${osdConfig.blockDeviceUdevRuleMatcher}, OWNER="${config.users.users.ceph.name}", GROUP="${config.users.groups.ceph.name}", MODE="0660"
          ''
          + lib.optionalString (osdConfig.dbBlockDeviceUdevRuleMatcher != null) (''
            SUBSYSTEM=="block", ${osdConfig.dbBlockDeviceUdevRuleMatcher}, OWNER="${config.users.users.ceph.name}", GROUP="${config.users.groups.ceph.name}", MODE="0660"
          '')
        ) cfg.osds
      );

      systemd.services = {

        ceph-mon-setup = mkIf cfg.monitor.enable {
          description = "Initialize ceph monitor";

          preStart = ensureCephDirs;

          script =
            let
              # `--addv` seems currently required to get msgr-v2 working, see:
              #     https://tracker.ceph.com/issues/53751#note-11
              monmapNodes = builtins.concatStringsSep " " (
                lib.concatMap (mon: [
                  "--addv"
                  mon.hostname
                  "[v2:${mon.ipAddress}:3300,v1:${mon.ipAddress}:6789]"
                ]) cfg.initialMonitors
              );
            in
            # Monitors cannot simply be changed in config, one has to update the monmap, see note [replacing-ceph-monmap-ips-for-existing-cluster]
            ''
              set -euo pipefail
              rm -rf "${monDir}" # Start from scratch.
              echo "Initializing monitor."
              MONMAP_DIR=`mktemp -d`
              ${cfg.package}/bin/monmaptool --create ${monmapNodes} --fsid ${cfg.fsid} "$MONMAP_DIR/monmap"
              ${cfg.package}/bin/ceph-mon --cluster ${cfg.clusterName} --mkfs -i ${cfg.monitor.nodeName} --monmap "$MONMAP_DIR/monmap" --keyring ${cfg.monitor.initialKeyring}
              rm -r "$MONMAP_DIR"
              touch ${monDir}/done
            '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            PermissionsStartOnly = true; # only run the script as ceph
            User = config.users.users.ceph.name;
            Group = config.users.groups.ceph.name;
          };
          unitConfig = {
            ConditionPathExists = "!${monDir}/done";
          };
        };

        ceph-mon = mkIf cfg.monitor.enable {
          description = "Ceph monitor";

          requires = [ (ensureUnitExists config "ceph-mon-setup.service") ];
          requiredBy = [ "multi-user.target" ];
          after = [
            "network.target"
            "local-fs.target"
            "time-sync.target"
            (ensureUnitExists config "ceph-mon-setup.service")
          ];
          wants = [
            "network.target"
            "local-fs.target"
            "time-sync.target"
          ];

          restartTriggers = [ config.environment.etc."ceph/${cfg.clusterName}.conf".source ];

          path = cephDeviceHealthMonitoringPathsOrPackages;

          preStart = ensureTransientCephDirs;

          serviceConfig = {
            LimitNOFILE = "1048576";
            LimitNPROC = "1048576";
            ExecStart = ''
              ${cfg.package}/bin/ceph-mon -f --cluster ${cfg.clusterName} --id ${cfg.monitor.nodeName} --setuser ${config.users.users.ceph.name} --setgroup ${config.users.groups.ceph.name} "--public_bind_addr=${cfg.monitor.bindAddr}" "--public_addr=${cfg.monitor.advertisedPublicAddr}"
            '';
            ExecReload = ''
              ${pkgs.coreutils}/bin/kill -HUP $MAINPID
            '';
            PrivateDevices = "yes";
            ProtectHome = "true";
            ProtectSystem = "full";
            PrivateTmp = "true";
            TasksMax = "infinity";
            Restart = "on-failure";
            # StartLimitBurst="5";
            RestartSec = "10";
          };
          # startLimitIntervalSec = 30 * 60;
        };

        ceph-mgr-setup = mkIf cfg.manager.enable {
          description = "Initialize Ceph manager";

          preStart = ensureCephDirs;

          script = ''
            set -euo pipefail
            mkdir -p ${mgrDir}
            until [ -f /etc/ceph/${cfg.clusterName}.client.admin.keyring ]
            do
              sleep 1
            done
            ${cfg.package}/bin/ceph auth get-or-create mgr.${cfg.manager.nodeName} mon 'allow profile mgr' mds 'allow *' osd 'allow *' -o ${mgrDir}/keyring
            touch "${mgrDir}/.nix_done"
          '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            PermissionsStartOnly = true; # only run the script as ceph
            User = config.users.users.ceph.name;
            Group = config.users.groups.ceph.name;
          };
          unitConfig = {
            ConditionPathExists = "!${mgrDir}/.nix_done";
          };
        };

        ceph-mgr = mkIf cfg.manager.enable {
          description = "Ceph manager";

          requires = [ (ensureUnitExists config "ceph-mgr-setup.service") ];
          requiredBy = [ "multi-user.target" ];
          after = [
            "network.target"
            "local-fs.target"
            "time-sync.target"
            (ensureUnitExists config "ceph-mgr-setup.service")
          ];
          wants = [
            "network.target"
            "local-fs.target"
            "time-sync.target"
          ];

          restartTriggers = [ config.environment.etc."ceph/${cfg.clusterName}.conf".source ];

          preStart = ensureTransientCephDirs;

          serviceConfig = {
            LimitNOFILE = "1048576";
            LimitNPROC = "1048576";

            ExecStart = ''
              ${cfg.package}/bin/ceph-mgr -f --cluster ${cfg.clusterName} --id ${cfg.manager.nodeName} --setuser ${config.users.users.ceph.name} --setgroup ${config.users.groups.ceph.name}
            '';
            ExecReload = ''
              ${pkgs.coreutils}/bin/kill -HUP $MAINPID
            '';
            Restart = "on-failure";
            RestartSec = 10;
            # StartLimitBurst="3";
          };
          # startLimitIntervalSec = 30 * 60;
        };

        ceph-mds-setup = mkIf cfg.mds.enable {
          description = "Initialize Ceph MDS";

          preStart = ensureCephDirs;

          script = ''
            set -euo pipefail
            mkdir -p ${mdsDir}
            until [ -f /etc/ceph/${cfg.clusterName}.client.admin.keyring ]
            do
              sleep 1
            done
            ${cfg.package}/bin/ceph auth get-or-create mds.${cfg.mds.nodeName} osd 'allow rwx' mds 'allow' mon 'allow profile mds' -o ${mdsDir}/keyring
            touch "${mdsDir}/.nix_done"
          '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            PermissionsStartOnly = true; # only run the script as ceph
            User = config.users.users.ceph.name;
            Group = config.users.groups.ceph.name;
          };
          unitConfig = {
            ConditionPathExists = "!${mdsDir}/.nix_done";
          };
        };

        ceph-mds = mkIf cfg.mds.enable {
          description = "Ceph MDS";

          requires = [ (ensureUnitExists config "ceph-mds-setup.service") ];
          requiredBy = [ "multi-user.target" ];
          after = [
            "network.target"
            "local-fs.target"
            "time-sync.target"
            (ensureUnitExists config "ceph-mds-setup.service")
          ];
          wants = [
            "network.target"
            "local-fs.target"
            "time-sync.target"
          ];

          restartTriggers = [ config.environment.etc."ceph/${cfg.clusterName}.conf".source ];

          preStart = ensureTransientCephDirs;

          serviceConfig = {
            LimitNOFILE = "1048576";
            LimitNPROC = "1048576";

            ExecStart = ''
              ${cfg.package}/bin/ceph-mds -f --cluster ${cfg.clusterName} --id ${cfg.mds.nodeName} --setuser ${config.users.users.ceph.name} --setgroup ${config.users.groups.ceph.name} "--public_addr=${cfg.mds.listenAddr}"
            '';
            ExecReload = ''
              ${pkgs.coreutils}/bin/kill -HUP $MAINPID
            '';
            Restart = "on-failure";
            # StartLimitBurst="3";
          };
          # startLimitIntervalSec = 30 * 60;
        };

      }
      # Make one OSD service for each configured OSD.
      // lib.mapAttrs' (
        localOsdServiceName: osdConfig:
        nameValuePair "ceph-osd-setup-${localOsdServiceName}" (
          makeCephOsdSetupSystemdService localOsdServiceName osdConfig
        )
      ) cfg.osds
      // lib.mapAttrs' (
        localOsdServiceName: osdConfig:
        nameValuePair "ceph-osd-${localOsdServiceName}" (
          makeCephOsdSystemdService localOsdServiceName osdConfig
        )
      ) cfg.osds;
    };
}
