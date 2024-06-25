defmodule ChatServiceWeb.MessagesComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <div>
          <p class="text-2xl px-4 py-4">Discussion</p>
          <div class="grid grid-cols-3 gap-4 px-4" id="chat-messages">
              <%= for content <- @message do %>

                  <div class="col-span-1 bg-blue-50 h-auto">
                      <%= content.user_name %>:
                  </div>
                  <div class="col-span-2 bg-blue-50 h-auto">
                      <%= content.messages %>
                  </div>
                  <% end %>
          </div>
          <div class="grid grid-cols-6 gap-10 py-6">

              <div class="col-start-2 col-end-6">
                  <input type="text" id="chat-input"
                      class="bg-blue-50 border border-blue-500 text-green-900 dark:text-blue-400 placeholder-blue-700 dark:placeholder-blue-500 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-blue-500"
                      placeholder="Type message">
              </div>
          </div>
      </div>
    """
  end

  @impl true
  def update(%{message: message}, %Phoenix.LiveView.Socket{transport_pid: nil} = socket) do
    {:ok, assign(socket, :message, message)}
  end

  @impl true
  def update(%{message: message}, socket) do
    {:ok, assign(socket, :message, message)}
  end

end
