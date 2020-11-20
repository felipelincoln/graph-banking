defmodule GraphBanking do
  @moduledoc """
  A public API for managing accounts and making transactions.
  """

  alias GraphBanking.{Account, Repo, Transaction}

  @type uuid :: Ecto.UUID
  @type changeset :: %Ecto.Changeset{}
  @type account :: %Account{}
  @type transaction :: %Transaction{}

  @doc """
  Gets a single account and associated transactions.

  ## Examples

      iex> get_account!("9b8dfc93-f59d-4de7-af60-57c535501ba9")
      %Account{
        current_balance: 0.0,
        transactions_in: [],
        transactions_out: [],
        uuid: "9b8dfc93-f59d-4de7-af60-57c535501ba9"
      }

  """
  @spec get_account!(uuid()) :: account()
  def get_account!(uuid) do
    Account
    |> Repo.get!(uuid)
    |> Repo.preload([:transactions_in, :transactions_out])
  end

  @doc """
  Creates an account.

  ## Examples

      iex> new_account(%{current_balance: 10})
      {:ok,
       %Account{
         current_balance: 10.0,
         uuid: "b92a8690-fb6e-425d-87f5-ea6ae16af83d",
         # ...
       }}

      iex> new_account(%{current_balance: -10})
      {:error, %Ecto.Changeset{}}

  """
  @spec new_account(map()) :: {:ok, account()} | {:error, changeset()}
  def new_account(params \\ %{}) do
    %Account{}
    |> Account.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Transfers the specified amount between the given accounts.

  In practice, this function creates a transaction  data and updates the accounts.
  If the sender account doesn't have the specified amount, it will rollback the transaction
  and restore the database to the previous state.

  ## Examples
  Lets start with a `sender` account, with an opening balance of `100.0`, and an
  `address` account with `0.0`.

      iex> {:ok, sender} = new_account(%{current_balance: 100})
      iex> {:ok, address} = new_account(%{current_balance: 0})

  Now we transfer `30.0` from `sender` to `address`.

      iex> transfer_money(sender.uuid, address.uuid, 30)
      # begin []
      # INSERT INTO "transactions" ...
      # UPDATE "accounts" ...
      # UPDATE "accounts" ...
      # commit []
      {:ok,
       %GraphBanking.Transaction{
         address_uuid: "3c11de5c-da6d-4a90-8d82-8432b1e4061f",
         amount: 30.0,
         sender_uuid: "d5cb1878-9fd4-4adc-8a44-2af0035de952",
         uuid: "d3020427-0b62-495e-b9f1-5d3160d77e84",
         when: ~U[2020-11-20 18:51:10Z],
         # ...
       }}

  If we check the current balance on both accounts we can see that it changed.

      iex> get_account!(sender.uuid)
      %GraphBanking.Account{
        current_balance: 70.0,
        uuid: "d5cb1878-9fd4-4adc-8a44-2af0035de952",
        # ...
      }
      iex> get_account!(address.uuid)
      %GraphBanking.Account{
        current_balance: 30.0,
        uuid: "3c11de5c-da6d-4a90-8d82-8432b1e4061f",
        # ...
      }

  We have now `70.0` on `sender` and `30.0` on `address`.  
  If we try to transfer again, but now the amount of `100.0`, we can see that it returns an error
  because `sender` has only `70.0` available on the account.

      iex> transfer_money(sender.uuid, address.uuid, 100)
      # begin []
      # INSERT INTO "transactions" ...
      # UPDATE "accounts" ...
      # UPDATE "accounts" ...
      # rollback []
      {:error, [current_balance: "can't be negative"]}

  The error states that the account can't have a negative balance and this constraint triggers
  the transaction rollback.

  """
  @spec transfer_money(uuid(), uuid(), float()) :: {:ok, transaction()} | {:error, keyword()}
  def transfer_money(sender_uuid, address_uuid, amount) do
    Repo.transaction(fn ->
      operation(sender_uuid, address_uuid, amount)
    end)
  rescue
    error ->
      [{field, {message, _opts}}] = error.changeset.errors
      {:error, [{field, message}]}
  end

  defp operation(sender_uuid, address_uuid, amount) do
    transaction =
      new_transaction!(%{sender_uuid: sender_uuid, address_uuid: address_uuid, amount: amount})

    sender = get_account!(sender_uuid)
    address = get_account!(address_uuid)

    update_account!(address, %{current_balance: address.current_balance + amount})
    update_account!(sender, %{current_balance: sender.current_balance - amount})

    transaction
  end

  defp new_transaction!(params) do
    %Transaction{}
    |> Transaction.changeset(params)
    |> Repo.insert!()
  end

  defp update_account!(%Account{} = account, params) do
    account
    |> Account.changeset(params)
    |> Repo.update!()
  end
end
