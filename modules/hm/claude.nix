{ config, lib, ... }:

let
  cfg = config.programs.claude-settings;
  configFile = {
    inherit (cfg) extraKnownMarketplaces;
    additionalDirectories = [
      "~/src"
    ] ++ cfg.additionalDirectories;
    allow = [
      "Agent(Plan)"
      "Bash(cargo build *)"
      "Bash(cargo run *)"
      "Bash(cargo test *)"
      "Bash(docker --version)"
      "Bash(docker build *)"
      "Bash(docker pull *)"
      "Bash(env)"
      "Bash(find *)"
      "Bash(git diff *)"
      "Bash(git log *)"
      "Bash(git ls-files *)"
      "Bash(git status)"
      "Bash(grep:*)"
      "Bash(jq:*)"
      "Bash(ls *)"
      "Bash(md5 *)"
      "Bash(podman --version)"
      "Bash(podman build *)"
      "Bash(podman pull *)"
      "Bash(pre-commit:*)"
      "Bash(python3 -c \"import yaml; list\\(yaml.safe_load_all\\(open\\('containers/.gitlab-ci.yml'\\)\\)\\)\")"
      "Bash(tox *)"
      "Bash(tr *)"
      "Bash(uv add *)"
      "Bash(uv run tox *)"
      "Bash(uv sync *)"
      "Bash(uv tool *)"
      "Bash(xargs ls -la)"
      "Edit(~/src/**)"
      "Read(~/.claude/**)"
      "Read(~/src/**)"
      "Read(//tmp/**)"
      "WebFetch(*)"

      "mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources"
      "mcp__plugin_atlassian_atlassian__getConfluencePage"
      "mcp__plugin_atlassian_atlassian__getIssueLinkTypes"
      "mcp__plugin_atlassian_atlassian__getJiraIssue"
      "mcp__plugin_atlassian_atlassian__getJiraIssueTypeMetaWithFields"
      "mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql"

      "mcp__claude_ai_Atlassian__addCommentToJiraIssue"
      "mcp__claude_ai_Atlassian__getAccessibleAtlassianResources"
      "mcp__claude_ai_Atlassian__getConfluencePage"
      "mcp__claude_ai_Atlassian__getJiraIssue"
      "mcp__claude_ai_Atlassian__getJiraIssueTypeMetaWithFields"
      "mcp__claude_ai_Atlassian__getIssueLinkTypes"
      "mcp__claude_ai_Atlassian__getTransitionsForJiraIssue"

      "mcp__claude_ai_Microsoft_365__sharepoint_folder_search"
      "mcp__claude_ai_Microsoft_365__sharepoint_search"
      "mcp__claude_ai_Microsoft_365__read_resource"
    ] ++ cfg.allow;
    ask = [
      "mcp__plugin_atlassian_atlassian__addCommentToJiraIssue"
      "mcp__plugin_atlassian_atlassian__createIssueLink"
      "mcp__plugin_atlassian_atlassian__editJiraIssue"

      "mcp__claude_ai_Atlassian__editJiraIssue"
      "mcp__claude_ai_Atlassian__createIssueLink"
      "mcp__claude_ai_Atlassian__transitionJiraIssue"
      "mcp__claude_ai_Atlassian__updateConfluencePage"
    ] ++ cfg.ask;
    defaultMode = cfg.defaultMode;
    deny = [
      "Bash(git commit *)"
      "Bash(git push *)"
      "Bash(rm -rf *)"
      "Edit(~/.claude/**)"
      "Read(~/.ssh/**)"
    ] ++ cfg.deny;
    enabledPlugins = lib.genAttrs cfg.enabledPlugins (p: true);
  };
  in {
    options = {
      programs.claude-settings = {
        additionalDirectories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        allow = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        ask = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        defaultMode = lib.mkOption {
          type = lib.types.enum [
            "default"
            "acceptEdits"
            "plan"
            "auto"
            "dontAsk"
            "bypassPermissions"
            "manual"
          ];
          default = "plan";
        };
        deny = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        enabledPlugins = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        extraKnownMarketplaces = lib.mkOption {
          type = lib.types.anything;
          default = {};
        };
      };
    };

    config = {
      home.file.".claude/settings.json".text = builtins.toJSON configFile;
    };
  }
