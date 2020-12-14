defmodule GraphBanking.Transaction do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [inserted_at: :when, updated_at: false, type: :utc_datetime]
  @primary_key {:uuid, :binary_id, autogenerate: true}
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
    |> validate_number(:amount, greater_than: 0, message: "is invalid")
    |> validate_uuid(:sender_uuid)
    |> validate_uuid(:address_uuid)
    |> validate_different(:sender_uuid, :address_uuid)
    |> assoc_constraint(:sender)
    |> assoc_constraint(:address)
  end

  defp validate_different(changeset, :ok, field2) do
    validate_change(changeset, :ok, fn _, value1 ->
      case get_change(changeset, field2) do
        ^value1 -> [address_uuid: "must be different from sender_uuid"]
        _ -> []
      end
    end)
  end

  defp validate_different(changeset, field1, field2) do
    validate_change(changeset, field1, fn _, value1 ->
      case get_change(changeset, field2) do
        ^value1 -> [address_uuid: "must be different from sender_uuid"]
        _ -> []
      end
    end)
  end

  defp validate_uuid(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      case Ecto.UUID.cast(value) do
        {:ok, _uuid} -> []
        :error -> [{field, "is invalid"}]
      end
    end)
  end
end
