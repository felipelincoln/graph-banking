defmodule GraphBanking.Account do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "accounts" do
    field :current_balance, :float

    has_many :transactions_in, GraphBanking.Transaction, foreign_key: :address_uuid
    has_many :transactions_out, GraphBanking.Transaction, foreign_key: :sender_uuid
  end

  def changeset(%GraphBanking.Account{} = acc, attrs) do
    acc
    |> cast(attrs, [:current_balance])
    |> validate_required(:current_balance)
    |> validate_number(:current_balance, greater_than_or_equal_to: 0)
  end
end
