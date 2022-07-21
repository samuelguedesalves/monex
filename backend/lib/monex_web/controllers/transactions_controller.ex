defmodule MonexWeb.TransactionsController do
  use MonexWeb, :controller

  alias Monex.{Error, User}
  alias MonexWeb.{FallbackController, Plugs.Authentication}

  action_fallback FallbackController

  plug Authentication

  def create(conn, %{"amount" => amount, "to_user_cpf" => to_user_cpf} = _params) do
    with {:ok, %User{id: user_id}} <- get_assign_user(conn),
         params <- %{amount: amount, to_user_cpf: to_user_cpf, from_user_id: user_id},
         {:ok, transaction} <- Monex.create_transaction(params) do
      conn
      |> put_status(:created)
      |> render("transaction.json", %{transaction: transaction})
    end
  end

  def create(_conn, _params), do: Error.build(:bad_request, "invalid params")

  def reverse(conn, %{"id" => transaction_id}) do
    with {:ok, %User{id: user_id}} <- get_assign_user(conn),
         {:ok, transaction} <- Monex.reverte_transaction(transaction_id, user_id) do
      conn
      |> put_status(:created)
      |> render("transaction.json", %{transaction: transaction})
    end
  end

  def show(conn, %{"id" => transaction_id}) do
    with {:ok, %User{id: user_id}} <- get_assign_user(conn),
         {:ok, transaction} <- Monex.get_transaction_by_id(transaction_id, user_id) do
      conn
      |> put_status(:ok)
      |> render("transaction.json", %{transaction: transaction})
    end
  end

  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()

    with {:ok, %User{id: user_id}} <- get_assign_user(conn),
         {:ok, result} <- Monex.get_transactions_by_user_id(user_id, page) do
      conn
      |> put_status(:ok)
      |> render("transaction_list.json", %{result: result})
    end
  end
end
