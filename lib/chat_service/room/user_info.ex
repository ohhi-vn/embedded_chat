defmodule ChatService.Room.UserInfo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:user_id, :string, autogenerate: false}
  schema "user" do
    has_many :chat, ChatService.Room.ChatInfo, foreign_key: :user_id, references: :user_id
    has_many :member, ChatService.Room.MemberInfo, foreign_key: :user_id, references: :user_id
    timestamps()

  end

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
