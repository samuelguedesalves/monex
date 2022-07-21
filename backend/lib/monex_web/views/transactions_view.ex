defmodule MonexWeb.TransactionsView do
  use MonexWeb, :view

  def render("transaction_list.json", %{result: params}) do
    %{
      next_page: next_page,
      page: page,
      transactions: transactions,
      quantity: quantity
    } = params

    %{
      next_page: next_page,
      page: page,
      transactions: render_many(transactions, __MODULE__, "transaction.json", as: :transaction),
      quantity: quantity
    }
  end

  def render("transaction.json", %{transaction: transaction}) do
    transaction
  end
end
