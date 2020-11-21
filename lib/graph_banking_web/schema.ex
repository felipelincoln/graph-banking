defmodule GraphBankingWeb.Schema do
  @moduledoc false
  use Absinthe.Schema
  alias GraphBankingWeb.Resolver

  object :transaction do
    field :uuid, :string
    field :address_uuid, :string, name: "address"
    field :amount, :float
    field :when, :string, resolve: &shift_timezone/3
  end

  defp shift_timezone(trans, _, _), do: {:ok, DateTime.add(trans.when, -10_800)}

  object :account do
    field :uuid, :string
    field :current_balance, :float
    field :transactions_out, list_of(:transaction), name: "transactions"
  end

  query do
    field :account, :account do
      arg(:uuid, non_null(:string))
      resolve(&Resolver.get_account/2)
    end
  end

  mutation do
    field :open_account, :account do
      arg(:current_balance, :float)
      resolve(&Resolver.new_account/2)
    end

    field :transfer_money, :transaction do
      arg(:sender, :string)
      arg(:address, :string)
      arg(:amount, :float)
      resolve(&Resolver.transfer_money/2)
    end
  end
end
