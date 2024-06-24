defmodule ChatService.Repo do
  use Ecto.Repo,
    otp_app: :chat_service,
    adapter: Ecto.Adapters.Postgres
end
