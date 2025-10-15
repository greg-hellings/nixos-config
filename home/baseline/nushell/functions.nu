# vim: set filetype=nushell :
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
        let build = ^nom build --keep-going $"/etc/nixos#nixosConfigurations.($hostname).config.system.build.toplevel"
        if $env.LAST_EXIT_CODE == 0 {
            nvd diff /run/current-system result
            run0 nixos-rebuild switch
        } else {
            print "Error during build"
        }
    }
}

def deploy [ $host: string, $build: string = "" ] {
    mut buildhost = $build
        if $build == "" {
            $buildhost = $host
        }
    if $buildhost == "linode" or $buildhost == "genesis" {
        $buildhost = "isaiah"
    }
    nixos-rebuild switch --sudo --use-substitutes --target-host $host --build-host $buildhost
}

def ff [ $file: string ] {
    ls **/* | where name =~ $file
}

def update_all [] {
    par-map $servers {|e| deploy $e | complete} | explore
}

def bake [template: string] {
    let copier = "~/.copier-templates" | path expand
    if not ($copier | path exists) {
        git clone srcpub:greg/copier-templates.git $copier
    }
    let srcdir = [$copier $template] | path join
    print $srcdir
    copier copy $srcdir .
}
