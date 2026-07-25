# vim: set filetype=nushell :
let servers = [isaiah jeremiah zeke genesis hosea]

def par-map [ items: list, c: closure ] {
  let results = $items | par-each -k $c
  $items | enumerate | reduce -f {} {|e, a| $a | upsert $e.item { $results | get $e.index }}
}

def --env unlock [] {
    if "BW_SESSION" not-in $env {
        $env.BW_SESSION = ^bw unlock --raw
    }
}

def nebulaIps [] {
    open /etc/nixos/network.json | get hosts | items { |h, e| $e.nebulaIp? } | where $it != null | sort
}

def genNebulaCert [ --ips: string, --name: string ] {
    let public = $'~/SynologyDrive/nebula/($name).key.pub' | path expand
    let private = $'~/SynologyDrive/nebula/($name).key' | path expand
    let cert = $'/etc/nixos/secrets/nebula/($name).crt'
    let ca_cert = '~/SynologyDrive/nebula/ca.crt' | path expand
    let ca_key = '~/SynologyDrive/nebula/ca.key' | path expand

    # Generate public key if there isn't one already
    if ( not ($public | path exists) ) {
        nebula-cert keygen -out-key $private -out-pub $public
    }
    # Clear old cert if there is one
    if ( $cert | path exists) {
        rm $cert
    }

    # Create and sign certs
    (nebula-cert sign
        -ca-crt $ca_cert
        -ca-key $ca_key
        -name $name
        -networks $ips
        -out-crt $cert
        -in-pub $public
    )

    # Agenix update
    cd /etc/nixos/secrets
    cat $private | agenix -e $'nebula/($name).key.age'
}


def rebuild [ $target: string = "switch" ] {
    if (uname | get operating-system) == "Darwin" {
        sudo darwin-rebuild $target
    } else {
        let hostname = uname | get nodename
        let build = ^nom build --keep-going $"/etc/nixos#nixosConfigurations.($hostname).config.system.build.toplevel"
        if $env.LAST_EXIT_CODE == 0 {
            nvd diff /run/current-system result
            run0 result/bin/switch-to-configuration $target
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
    colmena apply --on $host
    #nixos-rebuild switch --sudo --use-substitutes --target-host $host --build-host $buildhost
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

def podman_image_clean [] {
    podman rmi ...(^podman images --format=json | from json | where {|e| not ("Names" in $e)} | get Id)
}

def dc [ $cmd: string = "sh" ] {
    match $cmd {
        "up" => (devcontainer up --workspace-folder . --docker-path podman),
        "sh" => (devcontainer exec --workspace-folder . --docker-path podman bash),
        "down" => (podman compose -f .devcontainer/(open .devcontainer/devcontainer.json | get dockerComposeFile | first) down),
        _ => (devcontainer --help),
    }
}

if ("/usr/local/bin" | path exists) {
    $env.PATH = $env.PATH | append "/usr/local/bin"
}
$env.PATH = $env.PATH | prepend "~/.local/bin"
