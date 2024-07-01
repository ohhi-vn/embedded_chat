defmodule EmbeddedChatWeb.UserSocket do
  use Phoenix.LiveView.Socket

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels

  channel "lv:*", Phoenix.LiveView.Channel
  channel "game:*", EmbeddedChatWeb.GameChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
