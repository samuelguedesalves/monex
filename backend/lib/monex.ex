defmodule Monex do
  alias Monex.Transactions
  alias Monex.Users

  alias Transactions.Create, as: CreateTransaction
  alias Transactions.Get, as: GetTransaction
  alias Transactions.Reverte, as: ReverteTransaction

  alias Users.Auth, as: AuthUser
  alias Users.Create, as: CreateUser
  alias Users.Get, as: GetUser
  alias Users.GetAmount, as: GetAmountUser

  defdelegate create_user(params), to: CreateUser, as: :call
  defdelegate get_user_by_id(id), to: GetUser, as: :by_id
  defdelegate get_user_by_cpf(cpf), to: GetUser, as: :by_cpf
  defdelegate get_user_amount(user_id), to: GetAmountUser, as: :call
  defdelegate auth_user(params), to: AuthUser, as: :call

  defdelegate create_transaction(attrs), to: CreateTransaction, as: :call
  defdelegate get_transaction_by_id(transaction_id, user_id), to: GetTransaction, as: :by_id
  defdelegate get_transactions_by_user_id(user_id, page), to: GetTransaction, as: :by_user_id
  defdelegate reverte_transaction(transaction_id, user_id), to: ReverteTransaction, as: :call
end
