{ ... }:

let
  srcDomain = "src.thehellings.com";
  sshPort = 2222;
in
{
  greg.proxies."${srcDomain}" = {
    target = "https://gitea.shire-zebra.ts.net";
    ssl = true;
    genAliases = false;
    extraConfig = ''
      proxy_ssl_verify off;
      proxy_ssl_server_name on;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Ssl on;
      client_max_body_size 100000m;
      # Ultimate AI Block List v1.7 20250924
      # https://perishablepress.com/ultimate-ai-block-list/

      if ($http_user_agent ~* "(openai\.com|\.ai|-ai|_ai|ai\.|ai-|ai_|ai=|AddSearchBot|Agentic|AgentQL|Agent\ 3|Agent\ API|AI\ Agent|AI\ Article\ Writer|AI\ Chat|AI\ Content\ Detector|AI\ Detection|AI\ Dungeon|AI\ Journalist|AI\ Legion)") {
        return 444;
      }
      if ($http_user_agent ~* "(AI\ RAG|AI\ Search|AI\ SEO\ Crawler|AI\ Training|AI\ Web|AI\ Writer|AI2|AIBot|aiHitBot|AIMatrix|AISearch|AITraining|Alexa|Alice\ Yandex|AliGenie|AliyunSec|Alpha\ AI|AlphaAI|Amazon|Amelia)") {
        return 444;
      }
      if ($http_user_agent ~* "(AndersPinkBot|AndiBot|Anonymous\ AI|Anthropic|AnyPicker|Anyword|Applebot|Aria\ AI|Aria\ Browse|Articoolo|Ask\ AI|AutoGen|AutoGLM|Automated\ Writer|AutoML|Autonomous\ RAG|AwarioRssBot|AwarioSmartBot|AWS\ Trainium|Azure)") {
        return 444;
      }
      if ($http_user_agent ~* "(BabyAGI|BabyCatAGI|BardBot|Basic\ RAG|Bedrock|Big\ Sur|Bigsur|Botsonic|Brightbot|Browser\ MCP\ Agent|Browser\ Use|Bytebot|ByteDance|Bytespider|CarynAI|CatBoost|CC-Crawler|CCBot|Chai|Character)") {
        return 444;
      }
      if ($http_user_agent ~* "(Charstar\ AI|Chatbot|ChatGLM|Chatsonic|ChatUser|Chinchilla|Claude|ClearScope|Clearview|Cognitive\ AI|Cohere|Common\ Crawl|CommonCrawl|Content\ Harmony|Content\ King|Content\ Optimizer|Content\ Samurai|ContentAtScale|ContentBot|Contentedge)") {
        return 444;
      }
      if ($http_user_agent ~* "(ContentShake|Conversion\ AI|Copilot|CopyAI|Copymatic|Copyscape|CoreWeave|Corrective\ RAG|Cotoyogi|CRAB|Crawl4AI|CrawlQ\ AI|Crawlspace|Crew\ AI|CrewAI|Crushon\ AI|DALL-E|DarkBard|DataFor|DataProvider)") {
        return 444;
      }
      if ($http_user_agent ~* "(Datenbank\ Crawler|DeepAI|Deep\ AI|DeepL|DeepMind|Deep\ Research|DeepResearch|DeepSeek|Devin|Diffbot|Doubao\ AI|DuckAssistBot|DuckDuckGo\ Chat|DuckDuckGo-Enhanced|Echobot|Echobox|Elixir|FacebookBot|FacebookExternalHit|Factset)") {
        return 444;
      }
      if ($http_user_agent ~* "(Falcon|FIRE-1|Firebase|Firecrawl|Flux|Flyriver|Frase\ AI|FriendlyCrawler|Gato|Gemini|Gemma|Gen\ AI|GenAI|Generative|Genspark|Gentoo-chat|Ghostwriter|GigaChat|GLM|GodMode)") {
        return 444;
      }
      if ($http_user_agent ~* "(Goose|GPT|Grammarly|Grendizer|Grok|GT\ Bot|GTBot|GTP|Hemingway\ Editor|Hetzner|Hugging|Hunyuan|Hybrid\ Search\ RAG|Hypotenuse\ AI|iAsk|ICC-Crawler|ImageGen|ImagesiftBot|img2dataset|imgproxy)") {
        return 444;
      }
      if ($http_user_agent ~* "(INK\ Editor|INKforall|Instructor|IntelliSeek|Inferkit|ISSCyberRiskCrawler|Janitor\ AI|Jasper|Jenni\ AI|Julius\ AI|Kafkai|Kaggle|Kangaroo|Keyword\ Density\ AI|Kimi|Knowledge|KomoBot|Kruti|LangChain|Le\ Chat)") {
        return 444;
      }
      if ($http_user_agent ~* "(Lensa|Lightpanda|LinerBot|LLaMA|LLM|Local\ RAG\ Agent|Lovable|Magistral|magpie-crawler|Manus|MarketMuse|Meltwater|Meta-AI|Meta-External|Meta-Webindexer|Meta\ AI|MetaAI|MetaTagBot|Middleware|Midjourney)") {
        return 444;
      }
      if ($http_user_agent ~* "(Mini\ AGI|MiniMax|Mintlify|Mistral|Mixtral|model-training|Monica|Narrative|NeevaBot|netEstate|Neural\ Text|NeuralSEO|NinjaAI|NodeZero|Nova\ Act|NovaAct|OAI-SearchBot|OAI\ SearchBot|OASIS|Olivia)") {
        return 444;
      }
      if ($http_user_agent ~* "(Omgili|Open\ AI|Open\ Interpreter|OpenAGI|OpenAI|OpenBot|OpenPi|OpenRouter|OpenText\ AI|Operator|Outwrite|Page\ Analyzer\ AI|PanguBot|Panscient|Paperlibot|Paraphraser\.io|peer39_crawler|Perflexity|Perplexity|Petal)") {
        return 444;
      }
      if ($http_user_agent ~* "(Phind|PiplBot|PoeBot|PoeSearchBot|ProWritingAid|Proximic|Puppeteer|Python\ AI|Qualified|Quark|QuillBot|Qopywriter|Qwen|RAG\ Agent|RAG\ Azure\ AI|RAG\ Chatbot|RAG\ Database|RAG\ IS|RAG\ Pipeline|RAG\ Search)") {
        return 444;
      }
      if ($http_user_agent ~* "(RAG\ with|RAG-|RAG_|Raptor|React\ Agent|Redis\ AI\ RAG|RobotSpider|Rytr|SaplingAI|SBIntuitionsBot|Scala|Scalenut|Scrap|ScriptBook|Seekr|SEObot|SEO\ Content\ Machine|SEO\ Robot|SemrushBot|Sentibot)") {
        return 444;
      }
      if ($http_user_agent ~* "(Serper|ShapBot|Sidetrade|Simplified\ AI|Sitefinity|Skydancer|SlickWrite|SmartBot|Sonic|Sora|Spider/2|SpiderCreator|Spin\ Rewrite|Spinbot|Stability|StableDiffusionBot|Sudowrite|SummalyBot|Super\ Agent|Superagent)") {
        return 444;
      }
      if ($http_user_agent ~* "(SuperAGI|Surfer\ AI|TerraCotta|Text\ Blaze|TextCortex|Thinkbot|Thordata|TikTokSpider|Timpibot|Tinybird|Together\ AI|Traefik|TurnitinBot|uAgents|VelenPublicWebCrawler|Venus\ Chub\ AI|Vidnami\ AI|Vision\ RAG|WebSurfer|WebText)") {
        return 444;
      }
      if ($http_user_agent ~* "(Webzio|WeChat|Whisper|WordAI|Wordtune|WPBot|Writecream|WriterZen|Writescope|Writesonic|xAI|xBot|YaML|YandexAdditional|YouBot|Zendesk|Zero|Zhipu|Zhuque\ AI|Zimm)") {
        return 444;
      }
    '';
  };
  #greg.proxies."registry.thehellings.com" = {
  #target = "https://gitea.shire-zebra.ts.net:5000";
  #ssl = true;
  #genAliases = false;
  #extraConfig = ''
  #proxy_set_header X-Forwarded-Proto https;
  #proxy_set_header X-Forwarded-Ssl on;
  #client_max_body_size 25000m;
  #'';
  #};

  networking.firewall.allowedTCPPorts = [ sshPort ];

  systemd.services.haproxy = {
    after = [ "sys-devices-virtual-net-tailscale0.device" ];
  };

  services.haproxy = {
    enable = true;
    config = ''
      global
        daemon
        maxconn 20

      defaults
        timeout connect 500s
        timeout client 500s
        timeout server 1h

      listen gitsshd
        bind *:${toString sshPort}
        timeout client 1h
        mode tcp
        server git-isaiah isaiah.shire-zebra.ts.net:32222
        server git-jeremiah jeremiah.shire-zebra.ts.net:32222
        server git-zeke zeke.shire-zebra.ts.net:32222
    '';
  };
}
