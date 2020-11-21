defmodule GraphBankingWeb.Resolver do
  @moduledoc false

  def get_account(%{uuid: uuid}, _info) do
    {:ok, GraphBanking.get_account!(uuid)}
  rescue
    _ -> {:error, "Account #{uuid} doesn't exist."}
  end

  def new_account(params, _info) do
    case GraphBanking.new_account(params) do
      {:ok, account} ->
        # get the account with preloaded transactions
        {:ok, GraphBanking.get_account!(account.uuid)}

      {:error, _changeset} ->
        {:error, "Argument currentBalance must be a positive float."}
    end
  end

  def transfer_money(%{sender: sender, address: address, amount: amount}, _info) do
    case GraphBanking.transfer_money(sender, address, amount) do
      {:error, [{field, message}]} ->
        {:error, err_msg(field, message)}

      transaction ->
        transaction
    end
  end

  defp err_msg(:current_balance, _message), do: "Not enough balance for this transaction."
  defp err_msg(field, message), do: "#{field} #{message}."
end
