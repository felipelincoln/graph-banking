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

  test "update_account!/1 with valid data updates the account" do
    account = account_fixture()
    assert updated_account = GraphBanking.update_account!(account, %{current_balance: 10})
    assert updated_account.current_balance == 10
  end

  test "update_account!/1 with invalid data raises error" do
    account = account_fixture()

    assert_raise Ecto.InvalidChangesetError, fn ->
      GraphBanking.update_account!(account, %{current_balance: -10})
    end
  end

  test "new_transaction!/1 with valid data creates a transaction" do
    acc1 = account_fixture(100)
    acc2 = account_fixture()

    params = %{sender_uuid: acc1.uuid, address_uuid: acc2.uuid, amount: 50}
    assert transaction = GraphBanking.new_transaction!(params)
    assert transaction.sender_uuid == acc1.uuid
    assert transaction.address_uuid == acc2.uuid
    assert transaction.amount == 50

    # the following are indeed valid Transaction data.
    params = %{sender_uuid: acc2.uuid, address_uuid: acc1.uuid, amount: 50}
    assert transaction = GraphBanking.new_transaction!(params)
    assert transaction.sender_uuid == acc2.uuid
    assert transaction.address_uuid == acc1.uuid
    assert transaction.amount == 50

    params = %{sender_uuid: acc1.uuid, address_uuid: acc2.uuid, amount: 500}
    assert transaction = GraphBanking.new_transaction!(params)
    assert transaction.sender_uuid == acc1.uuid
    assert transaction.address_uuid == acc2.uuid
    assert transaction.amount == 500
  end

  test "new_transaction!/1 with invalid data raises error" do
    acc1 = account_fixture()
    acc2 = account_fixture()

    assert_raise Ecto.InvalidChangesetError, fn ->
      params = %{sender_uuid: acc1.uuid, address_uuid: acc2.uuid, amount: -50}
      GraphBanking.new_transaction!(params)
    end

    assert_raise Ecto.InvalidChangesetError, fn ->
      params = %{sender_uuid: "", address_uuid: acc2.uuid, amount: 50}
      GraphBanking.new_transaction!(params)
    end

    assert_raise Ecto.InvalidChangesetError, fn ->
      params = %{sender_uuid: acc1.uuid, address_uuid: "", amount: 50}
      GraphBanking.new_transaction!(params)
    end

    assert_raise Ecto.InvalidChangesetError, fn ->
      params = %{sender_uuid: Ecto.UUID.generate(), address_uuid: acc2.uuid, amount: 50}
      GraphBanking.new_transaction!(params)
    end

    assert_raise Ecto.InvalidChangesetError, fn ->
      params = %{sender_uuid: acc1.uuid, address_uuid: Ecto.UUID.generate(), amount: 50}
      GraphBanking.new_transaction!(params)
    end
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
