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
end
