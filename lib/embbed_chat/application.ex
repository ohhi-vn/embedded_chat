defmodule EmbeddedChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      EmbeddedChatWeb.Telemetry,
      # Start the Ecto repository
      EmbeddedChat.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: EmbeddedChat.PubSub},
      # Start the InternalPubSub system
      {Phoenix.PubSub, name: EmbeddedChat.InternalPubSub},
      # Start Finch
      {Finch, name: EmbeddedChat.Finch},
      # Start the Endpoint (http/https)
      EmbeddedChatWeb.Endpoint
      # Start a worker by calling: EmbeddedChat.Worker.start_link(arg)
      # {EmbeddedChat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EmbeddedChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EmbeddedChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
