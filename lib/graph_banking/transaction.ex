defmodule GraphBanking.Transaction do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [inserted_at: :when, updated_at: false, type: :utc_datetime]
  @primary_key {:uuid, :binary_id, [autogenerate: true]}
  @foreign_key_type :binary_id

  schema "transactions" do
    field :amount, :float

    timestamps()

    belongs_to :sender, GraphBanking.Account, references: :uuid, foreign_key: :sender_uuid
    belongs_to :address, GraphBanking.Account, references: :uuid, foreign_key: :address_uuid
  end

  def changeset(%GraphBanking.Transaction{} = trans, attrs) do
    trans
    |> cast(attrs, [:amount, :sender_uuid, :address_uuid])
    |> validate_required([:amount, :sender_uuid, :address_uuid])
    |> assoc_constraint(:sender)
    |> assoc_constraint(:address)
  end
end
