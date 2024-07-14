defmodule ChatService.Room.RoomActions do
  @moduledoc """
  ... Update later
  """

  alias ChatService.Room.ChatInfo
  alias ChatService.Room.RoomInfo
  alias ChatService.Room.UserInfo
  alias ChatService.Room.MemberInfo
  alias ChatService.Repo
  import Ecto.Query

  require Logger
  defmacro f_name() do
      elem(__CALLER__.function, 0)
  end

  @doc """
  Add RoomInfo entry with game id.
  """
  @spec add_room(map()) ::
    {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def add_room(attrs \\ %{}) do
    %RoomInfo{}
    |> RoomInfo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Add ChatInfo entry.
  """
  @spec add_chat(map()) ::
    {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def add_chat(attrs \\ %{}) do
    %ChatInfo{}
    |> ChatInfo.changeset(attrs, [:user_id, :room_id])
    |> Repo.insert()
  end

  @doc """
  Add UserInfo entry.
  """
  @spec add_user(map()) ::
    {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def add_user(attrs \\ %{}) do
    result =
      %UserInfo{}
      |> UserInfo.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, _} = ok ->
        ok
      # When user leaves room, we only delete user on MemberInfo table,
      # then user join room again, so we do not need to add user in UserInfo
      # table one more time
      {:error,
       %Ecto.Changeset{changes: %{user_id: user},
                       errors: [user_id: {"has already been taken", _}]}} ->

        {:ok, "#{user} has already been taken"}
      error ->
        error
    end
  end

  @doc """
  Add MemberInfo entry.
  """
  @spec add_member_with_room(map()) ::
  {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def add_member_with_room(attrs \\ %{}) do
    %MemberInfo{}
    |> MemberInfo.changeset(attrs, [:user_id, :room_id])
    |> Repo.insert()
  end

  @doc """
  Delete member (MemberInfo entry) in room.
  """
  @spec delete_member_in_room(integer(), String.t()) :: {:ok, Ecto.Schema.t()}
  def delete_member_in_room(room_id, user_id) do
    from(r in MemberInfo,
         where: r.room_id == ^room_id and r.user_id == ^user_id)
    |> Repo.delete_all()
  end


  @doc """
  Check whether channel_id is added into RoomInfo or not
  """
  @spec is_channel_exist_in_room(String.t()) :: boolean()
  def is_channel_exist_in_room(channel_id) do
    from(r in RoomInfo, where: r.channel_id == ^channel_id)
    |> Repo.exists?()
  end

  @doc """
  Check whether user_id is added into Room or not
  """
  @spec is_user_exist_in_room(integer(), String.t()) :: boolean()
  def is_user_exist_in_room(room_id, user_id) do
    from(r in MemberInfo,
         where: r.room_id == ^room_id and r.user_id == ^user_id)
    |> Repo.exists?()
  end

  @doc """
  Get user_id of chat room base on room_id
  """
  @spec get_user_id_in_room(integer()) :: list()
  def get_user_id_in_room(room_id) do
    from(c in MemberInfo, where: c.room_id == ^room_id, select: c.user_id)
    |> Repo.all()
  end

  @doc """
  Get all chat info in room
  """
  @spec get_chat_info(integer()) :: term()
  def get_chat_info(room_id) do
    query = from c in ChatInfo,
            order_by: c.id,
            where: c.room_id == ^room_id,
            select: %{user_name: c.user_id, messages: c.message}
    Repo.all(query)
  end

  @doc """
  Get room_id of chat room base on channel_id
  """
  @spec get_room_id_of_channel(String.t()) :: list()
  def get_room_id_of_channel(channel_id) do
    from(c in RoomInfo, where: c.channel_id == ^channel_id, select: c.room_id)
    |> Repo.all()
  end

  # @spec change_user(map()) :: term()
  def register_changeset() do
    UserInfo.registration_changeset(%UserInfo{})
  end
end
