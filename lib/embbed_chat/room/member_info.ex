defmodule EmbeddedChat.Room.MemberInfo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "member" do
    field :room_id, :integer
    field :user_id, :string

    belongs_to :user, EmbeddedChat.Room.UserInfo, foreign_key: :user_id, type: :string, references: :user_id, define_field: false
    belongs_to :room, EmbeddedChat.Room.RoomInfo, foreign_key: :room_id, references: :room_id, define_field: false

    timestamps()

  end

  def changeset(chat, params \\ %{}, [:user_id, :room_id]) do
    chat
    |> cast(params, [:user_id, :room_id])
    |> validate_required([:user_id, :room_id])
    # |> unique_constraint(:chat_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:room_id)
  end

end
