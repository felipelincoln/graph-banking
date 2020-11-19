defmodule GraphBanking.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table("transactions") do
      add :sender_uuid, references(:accounts, on_delete: :nothing, type: :uuid, column: :uuid)
      add :address_uuid, references(:accounts, on_delete: :nothing, type: :uuid, column: :uuid)
      add :amount, :float
      add :when, :utc_datetime
    end
  end
end
