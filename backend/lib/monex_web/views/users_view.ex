defmodule MonexWeb.UsersView do
  use MonexWeb, :view

  def render("created.json", %{user: user, token: token}) do
    %{
      message: "user are created!",
      user: user,
      token: "bearer #{token}"
    }
  end

  def render("authenticated.json", %{user: user, token: token}) do
    %{
      message: "user are authenticated!",
      user: user,
      token: "bearer #{token}"
    }
  end

  def render("show.json", %{user: user}), do: user
end
