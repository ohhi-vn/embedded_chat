defmodule ChatService.Room.ChatInfo do
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key {:chat_id, :id, autogenerate: true}
  schema "chat" do
    field :message, :string
    field :room_id, :integer
    field :user_id, :string

    belongs_to :user, ChatService.Room.UserInfo, foreign_key: :user_id, type: :string, references: :user_id, define_field: false
    belongs_to :room, ChatService.Room.RoomInfo, foreign_key: :room_id, references: :room_id, define_field: false

    timestamps()

  end

  def changeset(chat, params \\ %{}, [:user_id, :room_id]) do
    chat
    |> cast(params, [:message, :user_id, :room_id])
    |> validate_required([:message, :user_id, :room_id])
    # |> unique_constraint(:chat_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:room_id)
  end

end
