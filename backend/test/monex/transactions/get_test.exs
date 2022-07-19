defmodule Monex.Transactions.GetTest do
  use Monex.DataCase, async: true

  alias Monex.{Transaction, Transactions, User}

  import Monex.Factory

  describe "by_id/2" do
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

    test "when id are valid, return the transaction", %{
      transaction_id: transaction_id,
      receiver_user_id: receiver_user_id
    } do
      result = Transactions.Get.by_id(transaction_id, receiver_user_id)

      assert {:ok, %Transaction{}} = result
    end

    test "when id are invalid, return an error", %{
      receiver_user_id: receiver_user_id
    } do
      result = Transactions.Get.by_id(Ecto.UUID.generate(), receiver_user_id)

      expected_response = %Monex.Error{
        result: "transaction is not found",
        status: :bad_request
      }

      assert expected_response == result
    end
  end

  describe "by_user_id/2" do
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

    test "when user id is valid, return transactions list", %{
      receiver_user_id: receiver_user_id
    } do
      response = Transactions.Get.by_user_id(receiver_user_id, 1)

      expected_keys = [:next_page, :page, :quantity, :transactions]

      assert {:ok, result} = response
      assert true == Enum.all?(expected_keys, fn key -> Map.has_key?(result, key) end)
      assert [%Transaction{} | _tail] = result.transactions
    end
  end
end
