defmodule GraphBankingWeb.Router do
  @moduledoc false
  use GraphBankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GraphBankingWeb do
    pipe_through :api
  end
end
