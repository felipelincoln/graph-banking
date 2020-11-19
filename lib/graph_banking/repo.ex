defmodule GraphBanking.Repo do
  use Ecto.Repo,
    otp_app: :graph_banking,
    adapter: Ecto.Adapters.Postgres
end
