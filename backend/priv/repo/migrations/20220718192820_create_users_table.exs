defmodule Monex.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :name, :string, null: false
      add :cpf, :string, null: false
      add :initial_amount, :integer, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index("users", [:cpf])
    create constraint("users", :initial_amount, check: "initial_amount > 0")
  end
end
