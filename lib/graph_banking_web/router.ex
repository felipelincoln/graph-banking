defmodule GraphBankingWeb.Router do
  @moduledoc false
  use GraphBankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: GraphBankingWeb.Schema,
      interface: :simple
  end
end
