import Config

database_url =
  System.fetch_env!("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base =
  System.fetch_env!("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :web, Web.Endpoint,
  url: [host: "example.com", port: 443],
  https: [
    port: 4001,
    cipher_suite: :strong,
    keyfile: System.get_env("SSL_KEY_PATH"),
    certfile: System.get_env("SSL_CERT_PATH"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base,
  server: true,
  ecto_repos: [Db.Repo]

config :db, Db.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.fetch_env!("POOL_SIZE") || "10"),
  ecto_repos: [Db.Repo]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")
