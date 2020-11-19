defmodule GraphBanking.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :graph_banking,
    adapter: Ecto.Adapters.Postgres
end
