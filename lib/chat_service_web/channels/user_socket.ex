defmodule ChatServiceWeb.UserSocket do
  use Phoenix.LiveView.Socket

  channel "lv:*", Phoenix.LiveView.Channel
  channel "channel:*", ChatServiceWeb.GameChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
