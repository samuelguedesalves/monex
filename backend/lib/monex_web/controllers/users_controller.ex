defmodule MonexWeb.UsersController do
  use MonexWeb, :controller

  alias Monex.Error
  alias MonexWeb.{FallbackController, Plugs.Authentication}

  action_fallback FallbackController

  plug Authentication when action in [:show]

  def create(conn, params) do
    with {:ok, user, token} <- Monex.create_user(params) do
      conn
      |> put_status(:created)
      |> render("created.json", %{user: user, token: token})
    end
  end

  def show(conn, _params) do
    with {:ok, user} <- get_assign_user(conn) do
      conn
      |> put_status(:ok)
      |> render("show.json", %{user: user})
    end
  end

  def auth(conn, %{"cpf" => cpf, "password" => password} = _params) do
    attrs = %{cpf: cpf, password: password}

    with {:ok, %{user: user, token: token}} <- Monex.auth_user(attrs) do
      conn
      |> put_status(:ok)
      |> render("authenticated.json", %{user: user, token: token})
    end
  end

  def auth(_conn, _params) do
    Error.build(:bad_request, "missing or invalid params")
  end
end
