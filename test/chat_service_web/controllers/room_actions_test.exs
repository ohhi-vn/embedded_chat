defmodule ChatServiceWeb.RoomActionsTest do
  use ExUnit.Case, async: true
  use ChatServiceWeb.ConnCase, async: true
  alias ChatService.Room.RoomActions
  alias ChatService.Room.RoomInfo
  alias ChatService.Room.UserInfo
  alias ChatService.Room.MemberInfo
  alias ChatService.Room.ChatInfo

  doctest RoomActions

  @channel_id "123"
  @user_id_1 "john"
  @user_id_2 "david"
  @msg "hello"

  test "add room" do
      {:ok, room_info} = RoomActions.add_room(%{channel_id: @channel_id})
      assert %RoomInfo{channel_id: @channel_id} = room_info
  end

  test "add user" do
    {:ok, user} = RoomActions.add_user(%{user_id: @user_id_1})
    assert %UserInfo{user_id: @user_id_1} = user
  end

  test "add member in room" do
    add_data()
    [room_id] = RoomActions.get_room_id_of_channel(@channel_id)
    {:ok, member_info} = RoomActions.add_member_with_room(%{user_id: @user_id_1, room_id: room_id})

    assert %MemberInfo{room_id: ^room_id, user_id: @user_id_1} = member_info
  end

  test "save message of user" do
    add_data()
    [room_id] = RoomActions.get_room_id_of_channel(@channel_id)
    {:ok, chat_info} = RoomActions.add_chat(%{message: @msg, user_id: @user_id_1,
                                              room_id: room_id})
    assert %ChatInfo{room_id: ^room_id, user_id: @user_id_1, message: @msg} = chat_info
  end

  test "get user in room" do
    {:ok, _user1} = RoomActions.add_user(%{user_id: @user_id_1})
    {:ok, _user2} = RoomActions.add_user(%{user_id: @user_id_2})
    {:ok, _room_info} = RoomActions.add_room(%{channel_id: @channel_id})
    [room_id] = RoomActions.get_room_id_of_channel(@channel_id)
    {:ok, _member_info_1} = RoomActions.add_member_with_room(%{user_id: @user_id_1, room_id: room_id})
    {:ok, _member_info_2} = RoomActions.add_member_with_room(%{user_id: @user_id_2, room_id: room_id})
    users = RoomActions.get_user_id_in_room(room_id)
    assert [@user_id_2, @user_id_1] = users
  end

  defp add_data() do
    {:ok, _room_info} = RoomActions.add_room(%{channel_id: @channel_id})
    {:ok, _user} = RoomActions.add_user(%{user_id: @user_id_1})
  end

end
