defmodule ChatService.Repo.Migrations.CreateRoomTable do
  use Ecto.Migration

  def change do
    #  drop table("room")
    #  drop table("chat")
    #  drop table("user")
    #  drop table("member")

    create table(:room, primary_key: false) do
      add :room_id, :id, primary_key: true
      add :channel_id, :string, null: false

      timestamps()
    end

    create table(:chat) do
      add :message, :string, null: false
      add :user_id, references(:user, column: :user_id, type: :string)
      add :room_id, references(:room, column: :room_id)

      timestamps()
    end

    create table(:user, primary_key: false) do
      add :user_id, :string, primary_key: true, null: false

      timestamps()
    end

    create table(:member) do
      add :user_id, references(:user, column: :user_id, type: :string)
      add :room_id, references(:room, column: :room_id)

      timestamps()
    end

    create unique_index(:user, [:user_id])
    create unique_index(:room, [:room_id])
    create unique_index(:member, [:user_id, :room_id])

  end
end
