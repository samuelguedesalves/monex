defmodule MonexWeb.FallbackController do
  use MonexWeb, :controller

  alias Monex.Error
  alias MonexWeb.ErrorView

  def call(conn, %Error{status: status, result: result}) do
    conn
    |> put_status(status)
    |> put_view(ErrorView)
    |> render("error.json", %{result: result})
  end
end
