defmodule ChatService.Room.UserInfo do
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key {:chat_id, :id, autogenerate: true}
  # @primary_key false to disable generation of additional primary key fields.
  @primary_key {:user_id, :string, autogenerate: false}
  # @primary_key false
  schema "user" do
    # field :user_id, :string, primary_key: true
    # field :room_id, :integer
    # belongs_to :room, ChatService.Room.RoomInfo, foreign_key: :room_id, define_field: false
    has_many :chat, ChatService.Room.ChatInfo, foreign_key: :user_id, references: :user_id
    has_many :member, ChatService.Room.MemberInfo, foreign_key: :user_id, references: :user_id
    timestamps()

  end

  # def changeset(chat, params \\ %{}, [:room_id]) do
  #   chat
  #   |> cast(params, [:user_id, :room_id])
  #   |> validate_required([:user_id, :room_id])
  #   |> foreign_key_constraint(:room_id)
  # end

  def changeset(chat, params \\ %{}) do
    chat
    |> cast(params, [:user_id])
    |> unique_constraint(:user_id)
    |> validate_required([:user_id])
  end

  def registration_changeset(user, params \\ %{}) do
    cast(user, params, [])
  end
end
