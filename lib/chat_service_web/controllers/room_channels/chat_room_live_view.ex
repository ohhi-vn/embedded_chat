defmodule ChatServiceWeb.ChatRoomLiveView do
  use ChatServiceWeb, :live_view
  alias Phoenix.PubSub
  alias ChatService.Room.RoomActions

  @pubsub_chat_room Application.compile_env(:chat_service,
                                            [:pubsub, :chat_room])

  require Logger

  defmacro f_name() do
      elem(__CALLER__.function, 0)
  end

  @impl true
  def mount(params, session, socket) do
    {channel_id, user_id} =
      case is_map(params) do
        true ->
          {Map.get(params, "channel_id", :not_found),
           Map.get(params, "user_id", :not_found)}
        _ ->
          ## Use session when this live view is embeded in another liveview
          {Map.get(session, "channel_id", :not_found),
           Map.get(session, "user_id", :not_found)}
      end

    topic = "channel:" <> channel_id

    # subscribe to chat room with game id.
    changeset = RoomActions.register_changeset()

    new_socket =
      if connected?(socket) do
        :ok = PubSub.subscribe(@pubsub_chat_room, topic)
        is_channel_exist = RoomActions.is_channel_exist_in_room(channel_id)
        if is_channel_exist do
          :ok
        else
          RoomActions.add_room(%{channel_id: channel_id})
        end

        [room_id] = RoomActions.get_room_id_of_channel(channel_id)
        is_user_exist = RoomActions.is_user_exist_in_room(room_id, user_id)

        if is_user_exist do
          :ok
        else
          RoomActions.add_user(%{user_id: user_id})
          RoomActions.add_member_with_room(%{user_id: user_id, room_id: room_id})
        end
        # load all users in the room
        all_users = RoomActions.get_user_id_in_room(room_id)
        # load all history messages in the room
        message = RoomActions.get_chat_info(room_id)
        socket
        |> assign(:message, message)
        |> assign(:changeset, changeset)
        |> assign(:channel_id, channel_id)
        |> assign(:users_online, all_users)
        |> assign(:current_user, user_id)
      else
        socket
        |> assign(:message, [])
        |> assign(:channel_id, [])
        |> assign(:changeset, changeset)
        |> assign(:users_online, [])
        |> assign(:current_user, [])
      end

    {:ok, new_socket}
  end

  @impl true
  def handle_info({:join_room,
                   %{channel_id: channel_id, is_embedded: is_embedded,
                     user_id: user_id}},
                   socket) do
    [room_id] = RoomActions.get_room_id_of_channel(channel_id)
    all_users = RoomActions.get_user_id_in_room(room_id)

    new_all_users =
      if is_embedded == "true" and not Enum.member?(all_users, user_id) do
        all_users ++ [user_id]
      else
        all_users
      end

    update_users(new_all_users)
    {:noreply, assign(socket, :users_online, all_users)}
  end

  @impl true
  def handle_info({:send_msg,
                   %{body: body, user_id: user_id}},
                   %{assigns: %{message: old_msg}} = socket) do
    new_msg = old_msg ++ [%{messages: body, user_name: user_id}]
    # it will send update message to ChatServiceWeb.MessagesComponent
    # because we assign new :message for socket (socket is changed)
    {:noreply, assign(socket, :message, new_msg)}
  end

  def handle_info({:user_leave_room, %{user_id: user_id, channel_id: channel_id}},
                   %{assigns: %{users_online: old_all_users,
                                current_user: current_user}} = socket) do
    spawn(fn -> delete_user_in_room(channel_id, user_id) end)
    # Only redirect to other page for current user client, other clients will
    # stay at current page and will not redirect to other page.
    if (user_id == current_user) do
      {:noreply, push_redirect(socket, to: "/")}
    else
      update_users(old_all_users -- [user_id])
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:add_user_btn, %{room_id: room_id}}, socket) do
    all_users = RoomActions.get_user_id_in_room(room_id)
    new_socket =
      socket
      |> assign(:users_online, all_users)
    {:noreply, new_socket}
  end

  @impl true
  def handle_event("add_user_btn",%{"user_info" => %{"user_id" => user_id,
                                    "channel_id" => channel_id}}, socket) do
    topic = "channel:" <> channel_id
    case RoomActions.add_user(%{user_id: user_id}) do
      {:ok, _} ->
        [room_id] = RoomActions.get_room_id_of_channel(channel_id)
        RoomActions.add_member_with_room(%{user_id: user_id, room_id: room_id})
        if connected?(socket) do
          PubSub.broadcast(@pubsub_chat_room, topic, {:add_user_btn,
                                                      %{room_id: room_id}})
        end
        {:noreply, socket}
      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, inspect("user cannot empty!!"))}
    end
  end

  defp update_users(users) do
    send_update(ChatServiceWeb.UserOnlineComponent, id: "user_online",
                users_online: users)
  end

  defp delete_user_in_room(channel_id, user_id) do
    try do
      [room_id] = RoomActions.get_room_id_of_channel(channel_id)
      RoomActions.delete_member_in_room(room_id, user_id)
      :ok
    catch
      error, reason ->
        Logger.error("#{inspect self()}, cannot delete user in room with " <>
                     "param: #{inspect(%{channel_id: channel_id, user_id: user_id})}, error: " <>
                     "#{inspect(error)}, reason: #{inspect(reason)}")
        :error
      end
  end

end
