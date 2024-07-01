import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :embedded_chat, EmbeddedChat.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "embedded_chat_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :embedded_chat, EmbeddedChatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "b5HGKg8ZMwIZSj8/m65s0o0AQPVTXIhguM/6TTSa4C+48iPU4AOBDdf0lPz9yl2C",
  server: false

# In test we don't send emails.
config :embedded_chat, EmbeddedChat.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
