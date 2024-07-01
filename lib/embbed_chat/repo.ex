defmodule EmbeddedChat.Repo do
  use Ecto.Repo,
    otp_app: :embedded_chat,
    adapter: Ecto.Adapters.SQLite3
end
