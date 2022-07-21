defmodule MonexWeb.Helpers.GetAssignUser do
  alias Monex.Error
  alias Plug.Conn

  def call(%Conn{assigns: %{user: user}}), do: {:ok, user}
  def call(_conn), do: Error.build(:internal_server_error, "internal server error")
end
