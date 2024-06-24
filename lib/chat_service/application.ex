defmodule ChatService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChatServiceWeb.Telemetry,
      # Start the Ecto repository
      ChatService.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChatService.PubSub},
      # Start Finch
      {Finch, name: ChatService.Finch},
      # Start the Endpoint (http/https)
      ChatServiceWeb.Endpoint
      # Start a worker by calling: ChatService.Worker.start_link(arg)
      # {ChatService.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
