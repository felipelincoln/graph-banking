defmodule GraphBanking.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :current_balance, :float
    end
  end
end
