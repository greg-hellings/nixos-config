{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Prompts below use @PREFIX@ (agent-name prefix), @ROOT@ (the repository the
  # swarm was launched from) and @ENTERPRISE@ (the parent of @ROOT@); cswarm
  # substitutes them at launch.
  swarmProtocol = ''
    TEAM PROTOCOL. You are one of 5 Claude Code agents coordinating in herdr, in the tab @PREFIX@-team.
    Agents:
    - @PREFIX@-lead: the lead; the only agent that talks to the human.
    - @PREFIX@-reviewer: code reviewer.
    - @PREFIX@-researcher: researcher for anything external to the repository.
    - @PREFIX@-expert: expert on this repository (@ROOT@); plans and executes the work.
    - @PREFIX@-enterprise: expert on the whole enterprise, scoped to @ENTERPRISE@; read-only.
    Talk directly to each other with: herdr agent prompt <name> "<message>"
    Add --wait --timeout 300000 if you need to block until the recipient settles; otherwise send and continue.
    When you receive a message from another agent, reply to the sender the same way, starting with your own name.
    Keep messages concise and self-contained: the recipient has no shared context with you.
    Be as autonomous as possible and ask peers before asking the human.
    Only when you absolutely need a human decision, credential, or approval, message @PREFIX@-lead with the exact question and the options; the lead relays it to the human.
    Do not close panes or tabs you did not create and never run herdr server stop.
    Do not send anything or start work until @PREFIX@-lead gives you a task.
  '';
  reviewerPrompt = ''
    ${swarmProtocol}
    YOUR ROLE: code reviewer for the work we will be doing in this repository (@ROOT@).
    Review plans and diffs produced by @PREFIX@-expert for correctness, safety, consistency with the surrounding code's idioms, and regressions.
    Be read-only: do not edit files.
    Report only actionable findings, ranked by severity, to whoever asked (usually @PREFIX@-expert and @PREFIX@-lead).
  '';
  researcherPrompt = ''
    ${swarmProtocol}
    YOUR ROLE: researcher. Other agents ask you questions that need research external to this repository: websites, API and package documentation, release notes, and so forth.
    Use WebSearch and WebFetch.
    Answer with sources (URLs) and clearly separate verified facts from inference.
    Do not edit repository files.
  '';
  expertPrompt = ''
    ${swarmProtocol}
    YOUR ROLE: expert on this repository (@ROOT@). Learn its structure now.
    You plan and execute the work assigned by @PREFIX@-lead.
    Ask @PREFIX@-researcher for external facts and @PREFIX@-enterprise for how this work fits into the wider enterprise.
    Have @PREFIX@-reviewer review your plans and changes before you report them done.
    Do not commit, push, deploy, or apply system changes without explicit approval relayed from the human via @PREFIX@-lead.
  '';
  enterprisePrompt = ''
    ${swarmProtocol}
    YOUR ROLE: expert on the scope of the whole enterprise, rooted at your working directory @ENTERPRISE@ (the parent of @ROOT@).
    Other agents ask you where this work fits into the whole enterprise, and about the other services and libraries that support or depend on this project.
    You can only run gawk, herdr, ls, rg and grep, and cannot edit anything.
    Answer from evidence and cite file paths, and say plainly when something is outside your visible scope.
    You must use herdr to reply to peers.
  '';
  leadPrompt = ''
    You are @PREFIX@-lead, the lead agent of a 5-agent herdr swarm that cswarm has already started in the tab @PREFIX@-team.
    Do these first:
    1. Run: herdr agent rename "$HERDR_PANE_ID" @PREFIX@-lead
    2. Run: cswarm-guide, and follow it for all communication with the sub-agents.
    The sub-agents are briefed and idle, waiting for your first task.
    The human talks only to you. Delegate work to the sub-agents rather than doing it yourself, relay their human-interaction requests to the human, and relay the human's answers back.
    Wait for the human's first input before assigning work.
  '';
  claudeSwarm = pkgs.writeShellApplication {
    name = "cswarm";
    runtimeInputs = [
      claudeSwarmGuide
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.jq
      pkgs.ripgrep
    ];
    text = ''
      # Launch a herdr agent swarm: a 2x2 tab of reviewer, researcher, repo expert
      # and enterprise expert, then become the lead agent in this pane.
      test "''${HERDR_ENV:-}" = 1 || { echo "cswarm: must run inside a herdr pane" >&2; exit 1; }

      root=$PWD
      enterprise=$(dirname "$root")
      prefix=''${CSWARM_PREFIX:-$(basename "$root" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_\n-' '-' | cut -c1-12)}
      case $prefix in [a-z]*) ;; *) prefix="s$prefix" ;; esac

      for role in lead reviewer researcher expert enterprise; do
        if herdr agent list | jq -e --arg n "$prefix-$role" '.result.agents[] | select(.name == $n)' >/dev/null; then
          echo "cswarm: agent $prefix-$role already exists; set CSWARM_PREFIX to use another name" >&2
          exit 1
        fi
      done

      render() {
        local text
        text=$(cat "$1")
        text=''${text//@PREFIX@/$prefix}
        text=''${text//@ROOT@/$root}
        text=''${text//@ENTERPRISE@/$enterprise}
        printf '%s' "$text"
      }

      # A start that returns early is blocked on input (e.g. a folder trust
      # dialog) that only the human should answer; wait for it to clear.
      start_agent() {
        local name=$1 pane=$2
        shift 2
        if ! herdr agent start "$name" --kind claude --pane "$pane" -- "$@" >/dev/null; then
          echo "cswarm: $name is waiting for input in pane $pane (tab $prefix-team); answer it there" >&2
          herdr agent wait "$pane" --until idle --timeout 600000 >/dev/null
        fi
        herdr agent rename "$pane" "$name" >/dev/null
      }

      tab=$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$root" --label "$prefix-team" --no-focus)
      sleep 1
      reviewer_pane=$(jq -r .result.root_pane.pane_id <<<"$tab")
      researcher_pane=$(herdr pane split "$reviewer_pane" --direction right --cwd "$root" --no-focus | jq -r .result.pane.pane_id)
      expert_pane=$(herdr pane split "$reviewer_pane" --direction down --cwd "$root" --no-focus | jq -r .result.pane.pane_id)
      enterprise_pane=$(herdr pane split "$researcher_pane" --direction down --cwd "$enterprise" --no-focus | jq -r .result.pane.pane_id)

      start_agent "$prefix-reviewer" "$reviewer_pane" --permission-mode auto
      start_agent "$prefix-researcher" "$researcher_pane" --permission-mode auto
      start_agent "$prefix-expert" "$expert_pane" --permission-mode auto
      start_agent "$prefix-enterprise" "$enterprise_pane" \
        --tools Bash --permission-mode dontAsk \
        --allowedTools 'Bash(gawk:*)' 'Bash(herdr:*)' 'Bash(ls:*)' 'Bash(rg:*)' 'Bash(grep:*)'

      herdr agent prompt "$prefix-reviewer" "$(render ${pkgs.writeText "swarm-reviewer-prompt" reviewerPrompt})" >/dev/null
      herdr agent prompt "$prefix-researcher" "$(render ${pkgs.writeText "swarm-researcher-prompt" researcherPrompt})" >/dev/null
      herdr agent prompt "$prefix-expert" "$(render ${pkgs.writeText "swarm-expert-prompt" expertPrompt})" >/dev/null
      herdr agent prompt "$prefix-enterprise" "$(render ${pkgs.writeText "swarm-enterprise-prompt" enterprisePrompt})" >/dev/null

      export CSWARM_PREFIX=$prefix
      exec claude "$(render ${pkgs.writeText "swarm-lead-prompt" leadPrompt})"
    '';
  };
  claudeSwarmGuide = pkgs.writeShellApplication {
    name = "cswarm-guide";
    text = ''
      : "''${CSWARM_PREFIX:?run this from the lead agent started by cswarm}"
      p=$CSWARM_PREFIX
      cat <<EOF
      You are $p-lead. Your sub-agents (live herdr agents in the tab $p-team):
        $p-reviewer    code reviewer; read-only; reviews plans and diffs
        $p-researcher  external research: websites, API and package documentation
        $p-expert      expert on this repository; plans and executes the work
        $p-enterprise  expert on the enterprise scope (parent directory); read-only, only gawk/herdr/ls/rg/grep

      Delegate work to them; do not do it yourself. Route repository work to $p-expert,
      external questions to $p-researcher, enterprise-fit questions to $p-enterprise, and
      reviews to $p-reviewer.

      Send a task (self-contained; they share no context with you):
        herdr agent prompt $p-expert "<task>"
      Block until the recipient settles (idle/done/blocked), for short tasks:
        herdr agent prompt $p-expert "<task>" --wait --timeout 300000
      Replies arrive as herdr prompts into your own session; the agents message each other the same way.
      Read an agent's screen or check its state:
        herdr agent read $p-expert --source recent-unwrapped --lines 120
        herdr agent get $p-expert
        herdr agent list
      If an agent is blocked on an approval or question UI, inspect it with agent read.
      Do not answer security-relevant dialogs yourself; ask the human.

      Human interaction: the agents ask you when they absolutely need a human decision, credential or approval.
      Relay the exact question and options to the human, then send the answer back to the asking agent.
      Do not close panes or tabs, and never run herdr server stop.
      EOF
    '';
  };
in
{
  home.packages =
    with pkgs;
    [
      claudeSwarm
      claudeSwarmGuide
      dig
      jqp
      kubernetes-helm
      #iamb
      rainfrog
      ripgrep
      uv
      wiki-tui
    ]
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      impala
    ]);

  programs = {
    herdr = {
      enable = true;
      settings = {
        keys = {
          # Panel navigation
          focus_pane_down = "ctrl+j";
          focus_pane_left = "ctrl+h";
          focus_pane_right = "ctrl+l";
          focus_pane_up = "ctrl+k";
          # Tab navigation
          next_tab = "ctrl+shift+l";
          previous_tab = "ctrl+shift+h";
        };
        onboarding = false;
        terminal = {
          default_shell = lib.getExe config.programs.nushell.package;
          new_cwd = "follow";
          shell_mode = "auto";
        };
        theme = {
          name = "dracula";
          auto_switch = false;
        };
        ui = {
          sound.enabled = false;
          toast.delivery = "system";
        };
      };
    };
    zellij = {
      enable = true;
      enableZshIntegration = pkgs.stdenv.hostPlatform.isDarwin;
      settings = {
        #default_shell = "xonsh";
        default_shell = lib.getExe config.programs.nushell.package;
        plugins = {
          autolock = {
            _props.location = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
            _children = [
              {
                is_enabled = true;
              }
              {
                triggers = "nvim|vim|git";
              }
              {
                reaction_seconds = "0.3";
              }
              {
                print_to_log = true;
              }
            ];
          };
        };
        load_plugins.autolock = { };
        keybinds = {
          normal._children = [
            {
              bind = {
                _args = [ "Enter" ];
                _children = [
                  {
                    WriteChars = "\\u{000D}";
                    MessagePlugin = {
                      _args = [ "autolock" ];
                      _children = [ { } ];
                    };
                  }
                ];
              };
            }
          ]; # /normal
          locked._children = [
            {
              unbind = {
                _args = [ "Ctrl g" ];
              };
            }
          ];
          shared._children = [
            {
              bind = {
                _args = [ "Ctrl z" ];
                _children = [
                  {
                    MessagePlugin = {
                      _args = [ "autolock" ];
                      _children = [
                        {
                          payload._args = [ "toggle" ];
                        }
                      ];
                    };
                    SwitchToMode._args = [ "Normal" ];
                  }
                ];
              };
            }
          ]; # /locked
          shared_except = {
            _args = [ "locked" ];
            _children = [
              {
                bind = {
                  _args = [ "Ctrl h" ];
                  MoveFocusOrTab._args = [ "Left" ];
                };
              }
              {
                bind = {
                  _args = [ "Ctrl j" ];
                  MoveFocus._args = [ "Down" ];
                };
              }
              {
                bind = {
                  _args = [ "Ctrl k" ];
                  MoveFocus._args = [ "Up" ];
                };
              }
              {
                bind = {
                  _args = [ "Ctrl l" ];
                  MoveFocusOrTab._args = [ "Right" ];
                };
              }
            ];
          }; # /shared_except
        }; # /keybinds
      }; # /settings
    };
  };
}
