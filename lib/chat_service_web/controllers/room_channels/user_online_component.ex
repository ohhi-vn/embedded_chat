defmodule ChatServiceWeb.UserOnlineComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <div>

      <p class="text-2xl py-2 px-2">Current user onlines:</p>
      <div id="online-users">
          <%= for user <- @users_online do %>

              <p class="py-2 px-2">
                  <%= user %>
              </p>
              <% end %>

      </div>

      </div>
    """
  end

  @impl true
  def update(params, %Phoenix.LiveView.Socket{transport_pid: nil} = socket) do
    users_online = Map.get(params, :users_online, :users_online)
    {:ok, assign(socket, :users_online, users_online)}
  end

  @impl true
  def update(params, socket) do
    users_online = Map.get(params, :users_online, :users_online)
    {:ok, assign(socket, :users_online, users_online)}
  end

end
