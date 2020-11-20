defmodule GraphBanking do
  @moduledoc """
  GraphBanking keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias GraphBanking.{Account, Repo, Transaction}

  def get_account!(uuid) do
    Account
    |> Repo.get!(uuid)
    |> Repo.preload([:transactions_in, :transactions_out])
  end

  def new_account(params \\ %{}) do
    %Account{}
    |> Account.changeset(params)
    |> Repo.insert()
  end

  def update_account!(%Account{} = account, params \\ %{}) do
    account
    |> Account.changeset(params)
    |> Repo.update!()
  end

  def new_transaction!(params \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(params)
    |> Repo.insert!()
  end

  def transfer_money(sender_uuid, address_uuid, amount) do
    Repo.transaction(fn ->
      operation(sender_uuid, address_uuid, amount)
    end)
  rescue
    error -> error
  end

  defp operation(sender_uuid, address_uuid, amount) do
    new_transaction!(%{sender_uuid: sender_uuid, address_uuid: address_uuid, amount: amount})

    sender = get_account!(sender_uuid)
    address = get_account!(address_uuid)

    update_account!(sender, %{current_balance: sender.current_balance - amount})
    update_account!(address, %{current_balance: address.current_balance + amount})
  end
end
