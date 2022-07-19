defmodule Monex.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def change do
    create table("transactions") do
      add :amount, :integer, null: false
      add :from_user, references("users"), null: false
      add :to_user, references("users"), null: false
      add :old_transaction, references("transactions"), null: true

      timestamps(inserted_at: :processed_at)
    end

    create constraint("transactions", :amount, check: "amount > 0")
  end
end
