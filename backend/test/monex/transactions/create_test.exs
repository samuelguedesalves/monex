defmodule Monex.Transactions.CreateTest do
  use Monex.DataCase, async: true

  alias Monex.{Error, Transaction, Transactions, User}

  import Monex.Factory

  describe "call/1" do
    setup do
      %User{id: sender_user_id} = insert(:user)

      %User{cpf: receiver_user_cpf} =
        :user
        |> insert(%{name: "Gabriel", cpf: Brcpfcnpj.cpf_generate()})

      %{
        sender_user_id: sender_user_id,
        receiver_user_cpf: receiver_user_cpf
      }
    end

    test "when all params are valid, create the transaction", %{
      sender_user_id: sender_user_id,
      receiver_user_cpf: receiver_user_cpf
    } do
      params = %{
        amount: 2000,
        to_user_cpf: receiver_user_cpf,
        from_user_id: sender_user_id
      }

      response = Transactions.Create.call(params)

      assert {:ok, %Transaction{} = transaction} = response
      assert {:ok, _uuid} = Ecto.UUID.cast(transaction.from_user)
      assert {:ok, _uuid} = Ecto.UUID.cast(transaction.to_user)
    end

    test "when amount are invalid, return error struct with changeset", %{
      sender_user_id: sender_user_id,
      receiver_user_cpf: receiver_user_cpf
    } do
      params = %{
        amount: 0,
        to_user_cpf: receiver_user_cpf,
        from_user_id: sender_user_id
      }

      expected_response = %{amount: ["amount should be positive"]}

      assert %Error{result: changeset} = Transactions.Create.call(params)
      assert errors_on(changeset) == expected_response
    end

    test "when receiver cpf are invalid, return a error struct", %{
      sender_user_id: sender_user_id
    } do
      params = %{
        amount: 2000,
        to_user_cpf: Brcpfcnpj.cpf_generate(),
        from_user_id: sender_user_id
      }

      expected_response = %Error{
        result: "invalid receiver user cpf",
        status: :bad_request
      }

      response = Transactions.Create.call(params)

      assert expected_response == response
    end

    test "when sender id are invalid, return a error struct", %{
      receiver_user_cpf: receiver_user_cpf
    } do
      params = %{
        amount: 2000,
        to_user_cpf: receiver_user_cpf,
        from_user_id: Ecto.UUID.generate()
      }

      expected_response = %Error{
        result: "invalid user id",
        status: :internal_server_error
      }

      response = Transactions.Create.call(params)

      assert expected_response == response
    end
  end
end
