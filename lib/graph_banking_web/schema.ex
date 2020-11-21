defmodule GraphBankingWeb.Schema do
  @moduledoc false
  use Absinthe.Schema

  object :transaction do
    field :uuid, :string
    field :address_uuid, :string, name: "address"
    field :amount, :float
    field :when, :string, resolve: &shift_timezone/3
  end

  object :account do
    field :uuid, :string
    field :current_balance, :float
    field :transactions_out, list_of(:transaction), name: "transactions"
  end

  query do
    field :account, :account do
      arg(:uuid, non_null(:string))
      resolve(&get_account/2)
    end
  end

  mutation do
    field :open_account, :account do
      arg(:current_balance, :float)
      resolve(&new_account/2)
    end
  end

  defp get_account(%{uuid: uuid}, _info) do
    {:ok, GraphBanking.get_account!(uuid)}
  rescue
    _ -> {:error, "Account \"#{uuid}\"doesn't exist"}
  end

  defp new_account(params, _info) do
    case GraphBanking.new_account(params) do
      {:ok, account} ->
        {:ok, GraphBanking.get_account!(account.uuid)}
      {:error, changeset} ->
        {:error, "Argument \"currentBalance\" must be a positive float."}
    end
  end

  defp shift_timezone(trans, _, _), do: {:ok, DateTime.add(trans.when, -10_800)}
end
