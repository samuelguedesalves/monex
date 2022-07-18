defmodule Monex.Factory do
  use ExMachina.Ecto, repo: Monex.Repo

  alias Monex.User

  def user_params_factory do
    %{
      "name" => "Batatinha",
      "cpf" => Brcpfcnpj.cpf_generate(),
      "initial_amount" => 2_000_000,
      "password" => "123456"
    }
  end

  def user_factory do
    %User{
      name: "Samuel",
      cpf: "27024081171",
      initial_amount: 200_000,
      password: "123456",
      password_hash: Pbkdf2.hash_pwd_salt("123456")
    }
  end
end
