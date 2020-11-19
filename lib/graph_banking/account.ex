defmodule GraphBanking.Account do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "accounts" do
    field :currentBalance, :float

    has_many :transactions_in, GraphBanking.Transaction, foreign_key: :address_uuid
    has_many :transactions_out, GraphBanking.Transaction, foreign_key: :sender_uuid
  end

  def changeset(%GraphBanking.Account{} = acc, attrs) do
    acc
    |> cast(attrs, [:currentBalance])
    |> validate_required(:currentBalance)
  end
end
