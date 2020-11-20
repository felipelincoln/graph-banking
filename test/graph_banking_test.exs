defmodule GraphBankingTest do
  use GraphBanking.DataCase

  def account_fixture(balance \\ 0) do
    {:ok, account} = GraphBanking.new_account(%{current_balance: balance})

    account
  end

  test "get_account!/1 returns the account with given uuid" do
    account = account_fixture()
    assert GraphBanking.get_account!(account.uuid)
  end

  test "new_account/1 with valid data creates an account" do
    assert {:ok, account} = GraphBanking.new_account(%{current_balance: 0})
    assert account.current_balance == 0
  end

  test "new_account/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = GraphBanking.new_account(%{})
    assert {:error, %Ecto.Changeset{}} = GraphBanking.new_account(%{current_balance: -100})
  end

  test "transfer_money/3 with valid data creates a transaction and updates the accounts" do
    sender = account_fixture(500)
    address = account_fixture(100)

    assert {:ok, transaction} = GraphBanking.transfer_money(sender.uuid, address.uuid, 100)
    assert transaction.sender_uuid == sender.uuid
    assert transaction.address_uuid == address.uuid
    assert transaction.amount == 100

    assert GraphBanking.get_account!(sender.uuid).current_balance == 400
    assert GraphBanking.get_account!(address.uuid).current_balance == 200
  end

  test "transfer_money/3 with invalid data rollbacks the transaction and returns error reason" do
    sender = account_fixture(500)
    address = account_fixture(100)

    assert {:error, reason} = GraphBanking.transfer_money(sender.uuid, address.uuid, 600)
    assert [current_balance: "can't be negative"] == reason

    assert {:error, reason} = GraphBanking.transfer_money(sender.uuid, address.uuid, -100)
    assert [amount: "is invalid"] == reason

    assert {:error, reason} = GraphBanking.transfer_money(sender.uuid, address.uuid, 0)
    assert [amount: "is invalid"] == reason

    assert {:error, reason} = GraphBanking.transfer_money(sender.uuid, "", 100)
    assert [address_uuid: "can't be blank"] == reason

    assert {:error, reason} = GraphBanking.transfer_money(sender.uuid, Ecto.UUID.generate(), 100)
    assert [address: "does not exist"] == reason

    assert {:error, reason} = GraphBanking.transfer_money("", sender.uuid, 100)
    assert [sender_uuid: "can't be blank"] == reason

    assert {:error, reason} = GraphBanking.transfer_money(Ecto.UUID.generate(), address.uuid, 100)
    assert [sender: "does not exist"] == reason
  end
end
