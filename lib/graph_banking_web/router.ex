defmodule GraphBankingWeb.Router do
  use GraphBankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GraphBankingWeb do
    pipe_through :api
  end
end
