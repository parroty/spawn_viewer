use Mix.Config

config :phoenix, SpawnViewer.Router,
  port: System.get_env("PORT") || 4001,
  ssl: false,
  cookies: true,
  session_key: "_spawn_viewer_key",
  session_secret: "G1RR6GE7J4ZKIQC4K4GM%DCPG05YRK$WGBMS(&DZ#1GRJN)N1I((X%1ZRMDFBO961EDR+"

config :phoenix, :code_reloader,
  enabled: true

config :logger, :console,
  level: :debug


