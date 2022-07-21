defmodule MonexWeb.TransactionsControllerTest do
  use MonexWeb.ConnCase, async: true

  alias Monex.{Transaction, User}

  import Monex.Factory

  describe "create/2" do
    setup do
      build_two_users()
    end

    test "when params are valid, create the transaction", %{
      conn: conn,
      receiver_user_cpf: receiver_user_cpf,
      sender_user_token: token
    } do
      params = %{
        "amount" => 2000,
        "to_user_cpf" => receiver_user_cpf
      }

      response =
        conn
        |> put_req_header("authorization", "bearer #{token}")
        |> post("/api/transactions", params)
        |> json_response(:created)

      assert %{
               "amount" => amount,
               "from_user" => _from_user,
               "id" => _id,
               "old_transaction" => nil,
               "processed_at" => _processed_at,
               "to_user" => _to_user,
               "updated_at" => _updated_at
             } = response

      assert amount == params["amount"]
    end

    test "when a params are invalid, return a error", %{
      conn: conn,
      sender_user_token: token
    } do
      params = %{
        "amount" => 2000,
        "to_user_cpf" => Brcpfcnpj.cpf_generate()
      }

      response =
        conn
        |> put_req_header("authorization", "bearer #{token}")
        |> post("/api/transactions", params)
        |> json_response(:bad_request)

      expected_response = %{"error" => "invalid receiver user cpf"}

      assert expected_response == response
    end
  end

  describe "reverte/2" do
    setup do
      build_two_users()
      |> build_transaction()
    end

    test "when transaction user owner are valid, make transaction revert process", %{
      conn: conn,
      transaction_id: transaction_id,
      receiver_user_token: token
    } do
      response =
        conn
        |> put_req_header("authorization", "bearer #{token}")
        |> post("/api/transactions/reverse/#{transaction_id}")
        |> json_response(:created)

      assert %{
               "amount" => _,
               "from_user" => _,
               "id" => _,
               "old_transaction" => _,
               "processed_at" => _,
               "to_user" => _,
               "updated_at" => _
             } = response
    end

    test "when transaction user owner are invalid, return a error", %{
      conn: conn,
      transaction_id: transaction_id,
      sender_user_token: token
    } do
      response =
        conn
        |> put_req_header("authorization", "bearer #{token}")
        |> post("/api/transactions/reverse/#{transaction_id}")
        |> json_response(:bad_request)

      expected_response = %{"error" => "invalid transaction owner"}

      assert expected_response == response
    end
  end

  defp build_two_users do
    {:ok, %User{id: id}, sender_user_token} =
      :user_params
      |> build()
      |> Monex.create_user()

    {:ok, %User{cpf: cpf}, receiver_user_token} =
      :user_params
      |> build(%{"name" => "Abacate"})
      |> Monex.create_user()

    %{
      sender_user_id: id,
      receiver_user_cpf: cpf,
      receiver_user_token: receiver_user_token,
      sender_user_token: sender_user_token
    }
  end

  defp build_transaction(attrs) when is_map(attrs) do
    %{
      sender_user_id: sender_user_id,
      receiver_user_cpf: receiver_user_cpf,
      receiver_user_token: receiver_user_token,
      sender_user_token: sender_user_token
    } = attrs

    result =
      %{
        amount: 2000,
        to_user_cpf: receiver_user_cpf,
        from_user_id: sender_user_id
      }
      |> Monex.create_transaction()

    {:ok, %Transaction{id: transaction_id}} = result

    %{
      transaction_id: transaction_id,
      receiver_user_token: receiver_user_token,
      sender_user_token: sender_user_token
    }
  end
end
