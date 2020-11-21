defmodule GraphBankingWeb.Schema do
  @moduledoc false
  use Absinthe.Schema
  alias GraphBankingWeb.Resolver

  @desc """
  Transactions are currency operations between two accounts
  and it doens't keep the sender identifier.
  It is created by the `transferMoney` mutation.
  """
  object :transaction do
    field :uuid, :string, description: "The transaction's unique identifier."
    field :amount, :float, description: "The amount of money sent."

    field :address_uuid, :string,
      name: "address",
      description: "The account that received the money."

    field :when, :string,
      resolve: &shift_timezone/3,
      description: "When the operation took place."
  end

  @desc "Accounts are created by the `openAccount` mutation."
  object :account do
    field :uuid, :string, description: "The account's unique identifier."
    field :current_balance, :float, description: "The account's current balance."

    field :transactions_out, list_of(:transaction),
      name: "transactions",
      description: "All the transactions made."
  end

  @desc "The query root of GraphBanking's GraphQL interface."
  query do
    @desc "Gets a single account."
    field :account, :account do
      arg(:uuid, non_null(:string))
      resolve(&Resolver.get_account/2)
    end
  end

  @desc "The root query for implementing GraphQL mutations."
  mutation do
    @desc "Creates a new account."
    field :open_account, :account do
      arg(:current_balance, :float)
      resolve(&Resolver.new_account/2)
    end

    @desc "Transfer `amount` from `sender` to `address`."
    field :transfer_money, :transaction do
      arg(:sender, :string)
      arg(:address, :string)
      arg(:amount, :float)
      resolve(&Resolver.transfer_money/2)
    end
  end

  defp shift_timezone(trans, _, _), do: {:ok, DateTime.add(trans.when, -10_800)}
end
