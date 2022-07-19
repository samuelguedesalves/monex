defmodule Monex.Transactions.ReverseTest do
  use Monex.DataCase, async: true

  alias Monex.{Transaction, Transactions, User}

  import Monex.Factory

  describe "call/2" do
    setup do
      %User{id: sender_user_id} = insert(:user)

      %User{id: receiver_user_id} =
        :user
        |> insert(%{name: "Gabrile", cpf: Brcpfcnpj.cpf_generate()})

      %Transaction{id: transaction_id} =
        :transaction
        |> insert(%{from_user: sender_user_id, to_user: receiver_user_id})

      %{
        transaction_id: transaction_id,
        receiver_user_id: receiver_user_id
      }
    end

    test "when user are owner by transaction, reverse transaction", %{
      transaction_id: transaction_id,
      receiver_user_id: receiver_user_id
    } do
      response = Transactions.Reverte.call(transaction_id, receiver_user_id)

      assert {:ok, %Transaction{from_user: from_user}} = response
      assert from_user == receiver_user_id
    end

    test "when transaction owner id are invalid, return a error struct", %{
      transaction_id: transaction_id
    } do
      response = Transactions.Reverte.call(transaction_id, Ecto.UUID.generate())

      expected_response = %Monex.Error{
        result: "invalid transaction owner",
        status: :bad_request
      }

      assert expected_response == response
    end

    test "when transaction id are invalid, return a error struct", %{
      receiver_user_id: receiver_user_id
    } do
      response = Transactions.Reverte.call(Ecto.UUID.generate(), receiver_user_id)

      expected_response = %Monex.Error{
        result: "transaction not found",
        status: :bad_request
      }

      assert expected_response == response
    end
  end
end
