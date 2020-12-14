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
end
