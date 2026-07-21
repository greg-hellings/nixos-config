{
  modulesPath,
  top,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    top.hermes.nixosModules.default
  ];
  greg = {
    home = true;
    tailscale.enable = true;
  };
  nix.settings = {
    sandbox = false;
  };
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };
  services = {
    fstrim.enable = false;
    hermes-agent = {
      enable = true;
      settings = {
        agent = {
          reasoning_effort = "medium";
          reasoning_overrides = {
            claude-fable = "xhigh";
            claude-opus = "high";
          };
          tool_loop_guardrails = {
            hard_stop_enabled = true;
            warnings_enabled = true;
          };
          tool_use_enforcement = "auto";
        };
        code_execution = {
          mode = "strict";
          timeout = 300;
        };
        compression = {
          enabled = true;
          protect_first_n = 3;
          protect_last_n = 5;
          target_ratio = 0.25;
          threshold = 0.75;
        };
        context_file_max_chars = 25000;
        file_read_max_chars = 100000;
        goals = {
          max_turns = 20;  # Number of times Hermes tells the model to keep working towards the goal
        };
        memory = {
          memory_enabled = true;
          user_profile_enabled = true;
          write_approval = true;
        };
        quick_commands = {
          disk = {
            type = "exec";
            command = "df -h";
          };
          free = {
            type = "exec";
            command = "free -h";
          };
          restart = {
            type = "alias";
            target = "/gateway restart";
          };
        };
        skills = {
          guard_agent_created = true;
          write_approval = true;
        };
        stt = {
          enabled = true;
          echo_transcripts = true;
          provider = "local";
          local.model = "medium";
        };
        terminal = {
          backend = "local";
        };
        tool_output = {
          max_bytes = 50000;
          max_lines = 2000;
          max_line_length = 2000;
        };
        worktree = true; # Enable multiple agents in the same repo
      };
    };
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "yes";
      };
    };
    wyoming.faster-whisper.servers.medium = {
      enable = true;
      device = "cpu";
      initialPrompt = ''
        The user's name is 'Greg Hellings'. The street he lives on is 'Kardinal Court'
        in 'Midlothian'. Keep these in mind as they are often misspelled.
      '';
      language = "en";
      model = "medium";
      uri = "tcp://127.0.0.1:10300";
      sttLibrary = "faster-whisper";
    };
  };
}
