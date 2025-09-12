let servers = [isaiah jeremiah zeke genesis vm-gitlab vm-jellyfin]

def par-map [ items: list, c: closure ] {
  let results = $items | par-each -k $c
  $items | enumerate | reduce -f {} {|e, a| $a | upsert $e.item { $results | get $e.index }}
}

def --env unlock [] {
    if "BW_SESSION" not-in $env {
        $env.BW_SESSION = ^bw unlock --raw
    }
}

def rebuild [] {
    if (uname | get operating-system) == "Darwin" {
        sudo darwin-rebuild switch
    } else {
        let hostname = uname | get nodename
            let build = ^nom build $"/etc/nixos#nixosConfigurations.($hostname).config.system.build.toplevel" | complete
            if build.exit_code == 0 {
              	nvd diff /run/current-system result
              		sudo nixos-rebuild switch
            }
    }
}

def deploy [ $host: string, $build: string = "" ] {
    mut buildhost = $build
        if $build == "" {
            $buildhost = $host
        }
    if $buildhost == "linode" {
        $buildhost = "isaiah"
    }
    nixos-rebuild switch --use-remote-sudo --use-substitutes --target-host $host --build-host $buildhost | complete
}

def ff [ $file: string ] {
    ls **/* | where name =~ $file
}

def update_all [] {
    par-map $servers {|e| deploy $e} | explore
}
