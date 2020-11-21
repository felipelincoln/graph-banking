defmodule GraphBankingWeb.ResolverTest do
  use GraphBanking.DataCase

  alias GraphBanking.{Account, Transaction}
  alias GraphBankingWeb.Resolver

  def account_fixture(balance \\ 0) do
    {:ok, account} = GraphBanking.new_account(%{current_balance: balance})

    account
  end

  test "get_account/2 with existing uuid returns the account" do
    account = account_fixture()
    assert {:ok, %Account{}} = Resolver.get_account(%{uuid: account.uuid}, %{})
  end

  test "get_account/2 with invalid uuid returns error" do
    uuid = Ecto.UUID.generate()
    assert {:error, _err_msg} = Resolver.get_account(%{uuid: uuid}, %{})
  end

  test "new_account/2 with a positive balance returns the new account" do
    assert {:ok, %Account{}} = Resolver.new_account(%{current_balance: 10}, %{})
  end

  test "new_account/2 with a negative balance returns error" do
    assert {:error, _err_msg} = Resolver.new_account(%{current_balance: -10}, %{})
  end

  test "transfer_money/2 with valid data returns the new transaction" do
    sender = account_fixture(45.5)
    address = account_fixture(10)

    params = %{sender: sender.uuid, address: address.uuid, amount: 15.50}
    {:ok, %Transaction{}} = Resolver.transfer_money(params, %{})
  end

  test "transfer_money/2 with invalid data returns error" do
    sender = account_fixture(45.5)
    address = account_fixture(10)

    params = %{sender: sender.uuid, address: address.uuid, amount: 115.50}
    assert {:error, _err_msg} = Resolver.transfer_money(params, %{})

    params = %{sender: sender.uuid, address: address.uuid, amount: -115.50}
    assert {:error, _err_msg} = Resolver.transfer_money(params, %{})
  end
end
