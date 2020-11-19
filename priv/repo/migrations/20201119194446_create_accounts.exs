defmodule GraphBanking.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :currentBalance, :float
    end
  end
end
