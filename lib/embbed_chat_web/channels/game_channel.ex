defmodule EmbeddedChatWeb.GameChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub
  alias EmbeddedChat.Room.RoomActions
  alias Phoenix.LiveView.Socket

  use Phoenix.LiveView

  @pubsub_chat_room Application.compile_env(:embedded_chat,
                                            [:pubsub, :chat_room])

  require Logger

  @impl true
  def join("game:" <> game_id,
           %{"params" => payload},
           %Phoenix.Socket{transport_pid: transport_pid} = socket) do

    user_id = Map.get(payload, "user_id", :not_found)
    is_embedded = Map.get(payload, "is_embedded", :not_found)
    if authorized?(user_id, payload) do
      topic = "game:" <> game_id
      if connected?(%Socket{transport_pid: transport_pid}), do:
        PubSub.broadcast(@pubsub_chat_room, topic, {:join_room,
                                                    %{game_id: game_id,
                                                      is_embedded: is_embedded,
                                                      user_id: user_id}})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("new_msg", %{"body" => body, "user_id" => user_id},
                %Phoenix.Socket{transport_pid: transport_pid,
                                topic: "game:" <> game_id} = socket) do
    if connected?(%Socket{transport_pid: transport_pid}) do
      topic = "game:" <> game_id
      spawn(fn -> save_message(game_id, body, user_id) end)
      PubSub.broadcast(@pubsub_chat_room, topic, {:send_msg,
                                                  %{body: body,
                                                    user_id: user_id,
                                                    game_id: game_id}})
     end
    {:noreply, socket}
  end

  @impl true
  def handle_in("user_leave_room", %{"user_id" => user_id},
                %Phoenix.Socket{transport_pid: transport_pid,
                                topic: "game:" <> game_id} = socket) do

    if connected?(%Socket{transport_pid: transport_pid}) do
      topic = "game:" <> game_id
      PubSub.broadcast(@pubsub_chat_room, topic,
                       {:user_leave_room,
                        %{user_id: user_id, game_id: game_id}})
     end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_user_id, _payload) do
    true
  end

  # save message into database.
  defp save_message(game_id, body, user_id) do
    [room_id] = RoomActions.get_room_id_of_game(game_id)
    {:ok, _} = RoomActions.add_chat(%{message: body, user_id: user_id,
                                      room_id: room_id})
  end

end
