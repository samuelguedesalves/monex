defmodule Monex.TransactionTest do
  use Monex.DataCase, async: true

  alias Ecto.Changeset
  alias Monex.{Transaction, User}

  import Monex.Factory

  describe "changeset/1" do
    test "when all params are valid, return a valid transaction changeset" do
      %User{id: sender_user_id} = insert(:user)

      %User{id: receiver_user_id} =
        insert(:user, %{name: "Gabriel", cpf: Brcpfcnpj.cpf_generate()})

      params = %{
        amount: 1000,
        from_user: sender_user_id,
        to_user: receiver_user_id
      }

      result = Transaction.changeset(params)

      assert %Changeset{valid?: true, changes: changes} = result
      assert params.from_user == changes.from_user
      assert params.to_user == changes.to_user
      assert params.amount == changes.amount
    end

    test "when are missing a field, returns changeset error" do
      params = %{
        amount: 1000
      }

      result = Transaction.changeset(params)

      expected_result = %{from_user: ["can't be blank"], to_user: ["can't be blank"]}

      assert errors_on(result) == expected_result
    end
  end
end
