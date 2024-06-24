defmodule ChatService.Repo do
  use Ecto.Repo,
    otp_app: :chat_service,
    adapter: Ecto.Adapters.SQLite3
end
