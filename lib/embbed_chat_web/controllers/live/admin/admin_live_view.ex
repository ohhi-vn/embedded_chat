defmodule EmbeddedChatWeb.AdminLiveView do
  use EmbeddedChatWeb, :live_view

  alias Phoenix.PubSub

  def mount(_params, _session, socket) do


    {:ok, assign(socket, :message, "Hello World")}
  end

end
