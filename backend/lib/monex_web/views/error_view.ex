defmodule MonexWeb.ErrorView do
  use MonexWeb, :view

  alias Ecto.Changeset

  import Ecto.Changeset, only: [traverse_errors: 2]

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("error.json", %{result: %Changeset{} = changeset}) do
    %{error: translate_errors(changeset)}
  end

  def render("error.json", %{result: result}) do
    %{error: result}
  end

  defp translate_errors(%Changeset{} = changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
