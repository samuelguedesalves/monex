defmodule MonexWeb.UsersControllerTest do
  use MonexWeb.ConnCase, async: true

  alias Monex.User

  import Monex.Factory

  describe "create/2" do
    test "when all params are valid, create the user", %{conn: conn} do
      response =
        conn
        |> post("/api/sign_up", build(:user_params))
        |> json_response(:created)

      user_fields = ~w[cpf id initial_amount inserted_at name updated_at]

      assert %{
               "message" => "user are created!",
               "token" => "bearer " <> _tail,
               "user" => user
             } = response

      assert true == Enum.all?(user_fields, fn key -> Map.has_key?(user, key) end)
    end

    test "when has has invalid params, return erro view", %{conn: conn} do
      response =
        conn
        |> post("/api/sign_up", build(:user_params, %{"initial_amount" => 0}))
        |> json_response(:bad_request)

      expected_response = %{
        "error" => %{"initial_amount" => ["initial_amount should be positive"]}
      }

      assert expected_response == response
    end
  end

  describe "show/2" do
    setup do
      {:ok, _user, token} =
        :user_params
        |> build()
        |> Monex.create_user()

      %{token: token}
    end

    test "when has authentication access token, return the user", %{conn: conn, token: token} do
      response =
        conn
        |> put_req_header("authorization", "bearer #{token}")
        |> get("/api/users/details")
        |> json_response(:ok)

      user_fields = ~w[cpf id initial_amount inserted_at name updated_at]

      assert true == Enum.all?(user_fields, fn key -> Map.has_key?(response, key) end)
    end

    test "when token are missing, return authentication error", %{conn: conn} do
      response =
        conn
        |> get("/api/users/details")
        |> json_response(:unauthorized)

      assert %{"error" => "invalid access token"} == response
    end
  end

  describe "auth/2" do
    setup do
      %User{cpf: cpf, password: password} = insert(:user)

      %{cpf: cpf, password: password}
    end

    test "when cpf and password are valid, return the user and token", %{
      conn: conn,
      cpf: cpf,
      password: password
    } do
      response =
        conn
        |> post("/api/login", %{"cpf" => cpf, "password" => password})
        |> json_response(:ok)

      user_fields = ~w[cpf id initial_amount inserted_at name updated_at]

      assert %{
               "message" => "user are authenticated!",
               "token" => "bearer " <> _tail,
               "user" => user
             } = response

      assert true == Enum.all?(user_fields, fn key -> Map.has_key?(user, key) end)
    end
  end
end
