use Mix.Config

# NOTE: To get SSL working, you will need to set:
#
#     ssl: true,
#     keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#     certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#
# Where those two env variables point to a file on disk
# for the key and cert

config :phoenix, SpawnViewer.Router,
  port: System.get_env("PORT"),
  ssl: false,
  host: "example.com",
  cookies: true,
  session_key: "_spawn_viewer_key",
  session_secret: "G1RR6GE7J4ZKIQC4K4GM%DCPG05YRK$WGBMS(&DZ#1GRJN)N1I((X%1ZRMDFBO961EDR+"

config :logger, :console,
  level: :info,
  metadata: [:request_id]

