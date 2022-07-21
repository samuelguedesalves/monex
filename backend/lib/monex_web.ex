defmodule MonexWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use MonexWeb, :controller
      use MonexWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  alias Monex.{Error, User}
  alias MonexWeb.Helpers.GetAssignUser

  def controller do
    quote do
      use Phoenix.Controller, namespace: MonexWeb

      import Plug.Conn
      alias MonexWeb.Router.Helpers, as: Routes

      @doc """
      Get assign user

      ## Params
      - conn: represent the connection

      ## Example

          def index(conn, _params) do
            {:ok, %User{name: name}} = get_assign_user(conn)

            conn
            |> put_status(:ok)
            |> json(%{username: name})
          end
      """
      @spec get_assign_user(conn :: Plug.Conn.t()) :: {:ok, User.t()} | Error.t()
      def get_assign_user(conn), do: GetAssignUser.call(conn)
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/monex_web/templates",
        namespace: MonexWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defp view_helpers do
    quote do
      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import MonexWeb.ErrorHelpers
      alias MonexWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
