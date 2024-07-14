import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/chat_service start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :chat_service, ChatServiceWeb.Endpoint, server: true
end

if config_env() == :prod do

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []
  db_file = System.get_env("DATABASE_FILE") || raise "missing DATABASE_FILE environment variable"
  host = System.get_env("PHX_HOST") || raise "missing PHX_HOST environment variable"
  port = String.to_integer(System.get_env("PHX_HTTP_PORT") || "8080")

  IO.puts("Runtime configuration db_file_database: #{Path.expand("../#{db_file}", Path.dirname(__ENV__.file))}")
  IO.puts("Runtime configuration db_file: #{db_file}")

  config :chat_service, ChatService.Repo,
    # ssl: true,
    database: Path.expand(db_file),
    stacktrace: true,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in cosnfig/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :chat_service, ChatServiceWeb.Endpoint,
    url: [host: host, port: port, scheme: "http"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :chat_service, ChatServiceWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your endpoint, ensuring
  # no data is ever sent via http, always redirecting to https:
  #
  #     config :chat_service, ChatServiceWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :chat_service, ChatService.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
  database1 = Path.expand("../chat_service_dev.db")
  database2 = Path.expand("../chat_service_dev.db", Path.dirname(__ENV__.file))
  database3 = Path.dirname(__ENV__.file)

  check = :os.cmd('ls chat_service_dev.db')
  check2 = :os.cmd('ls ../chat_service_dev.db')

  IO.puts("Runtime configuration loaded database1, env: #{database1}")
  IO.puts("Runtime configuration loaded database2, env: #{database2}")
  IO.puts("Runtime configuration loaded database3, env: #{database3}")
  IO.puts("Runtime configuration loaded check, env: #{inspect(check)}")
  IO.puts("Runtime configuration loaded check2, env: #{inspect(check2)}")


  IO.puts("Runtime configuration loaded host, env: #{host}")
  IO.puts("Runtime configuration loaded port, env: #{port}")
  IO.puts("Runtime configuration loaded, env: #{config_env()}")

end
