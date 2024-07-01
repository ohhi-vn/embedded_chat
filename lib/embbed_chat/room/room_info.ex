defmodule EmbeddedChat.Room.RoomInfo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:room_id, :id, autogenerate: true}
  schema "room" do
    field :game_id, :string
    has_many :chat, EmbeddedChat.Room.ChatInfo, foreign_key: :room_id, references: :room_id
    has_many :member, EmbeddedChat.Room.MemberInfo, foreign_key: :room_id, references: :room_id

    timestamps()

  end

  def changeset(room, params \\ %{}) do
    room
    |> cast(params, [:game_id])
    |> validate_required([:game_id])
    |> unique_constraint(:room_id)
  end

end
