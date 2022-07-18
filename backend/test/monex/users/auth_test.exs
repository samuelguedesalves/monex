defmodule Monex.Users.AuthTest do
  use Monex.DataCase, async: true

  alias Ecto.UUID
  alias Monex.{AuthGuardian, Error, User, Users}

  import Monex.Factory

  describe "call/1" do
    setup do
      %User{cpf: cpf, password: password} = insert(:user)

      %{cpf: cpf, password: password}
    end

    test "when cpf and password is valid, return user struct and an valid access token", %{
      cpf: cpf,
      password: password
    } do
      params = %{cpf: cpf, password: password}

      assert {:ok, %{user: %User{id: user_id}, token: token}} = Users.Auth.call(params)

      assert {:ok, %{"sub" => sub}} = AuthGuardian.decode_and_verify(token)
      assert {:ok, sub_user_id} = UUID.cast(sub)
      assert user_id == sub_user_id
    end

    test "when password are invalid, return access error", %{cpf: cpf} do
      params = %{
        cpf: cpf,
        password: "000000"
      }

      response = Users.Auth.call(params)

      expected_response = %Error{result: "invalid password", status: :bad_request}

      assert expected_response == response
    end

    test "when cpf not is respective to any user, return not found error" do
      params = %{
        cpf: Brcpfcnpj.cpf_generate(),
        password: "000000"
      }

      response = Users.Auth.call(params)

      expected_response = %Error{result: "user is not found", status: :not_found}

      assert expected_response == response
    end
  end
end
