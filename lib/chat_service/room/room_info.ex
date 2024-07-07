defmodule ChatService.Room.RoomInfo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:room_id, :id, autogenerate: true}
  schema "room" do
    field :channel_id, :string
    has_many :chat, ChatService.Room.ChatInfo, foreign_key: :room_id, references: :room_id
    has_many :member, ChatService.Room.MemberInfo, foreign_key: :room_id, references: :room_id

    timestamps()

  end

  def changeset(room, params \\ %{}) do
    room
    |> cast(params, [:channel_id])
    |> validate_required([:channel_id])
    |> unique_constraint(:room_id)
  end

end
