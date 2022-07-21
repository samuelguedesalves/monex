defmodule MonexWeb.Plugs.Authentication do
  import Plug.Conn

  alias Monex.{AuthGuardian, Users.Get}

  def init(default), do: default

  def call(conn, _default) do
    with {:ok, token} <- get_connection_token(conn),
         {:ok, user_id} <- verify_token(token),
         {:ok, user} <- Get.by_id(user_id) do
      assign(conn, :user, user)
    else
      _ -> render_error(conn)
    end
  end

  defp get_connection_token(conn) do
    with token when token != [] <- get_req_header(conn, "authorization"),
         [token | _tail] <- token,
         ["bearer", token] <- String.split(token, " ") do
      {:ok, token}
    end
  end

  defp verify_token(token) do
    case AuthGuardian.decode_and_verify(token) do
      {:ok, %{"sub" => id}} -> {:ok, id}
      _ -> :error
    end
  end

  defp render_error(conn) do
    body = Jason.encode!(%{error: "invalid access token"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, body)
    |> halt()
  end
end
