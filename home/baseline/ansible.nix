{ ... }:

{
  home.file.".ansible.cfg".text = ''
    [defaults]
    forks=10
    host_key_checking=False
    # Also available: profile_roles
    callback_enabled=timer,profile_tasks
    callback_result_format=yaml
    nocows=1
    cow_selection=tux
    collections_path=~/src

    [ssh_connection]
    pipelining=True
    ssh_args = -o ControlMaster=auto -o ControlPersist=600s -o IdentitiesOnly=yes -o GSSAPIAuthentication=no -o StrictHostKeyChecking=no
    control_path=%(directory)s/%%h-%%r
    control_path_dir=/tmp

    [callback_profile_tasks]
    sort_order=descending

    [galaxy]
    role_skeleton_ignore = ^.git$,^.*/.git_keep$,\..*.swp
    role_skeleton = ~/src/ansible_collections/meta_ansible_templates/role
  '';
}
