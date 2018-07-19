defmodule ExBanking.User.Wallet do
  @moduledoc """
  This module works as a safe wallet to the users.
  """
  alias ExBanking.Transaction

  def deposit(%Transaction{receiver: user, amount: amount, currency: currency}) do
    new_balance = :ets.update_counter(__MODULE__, {user, currency}, amount, {{user, currency}, 0})
    {:ok, new_balance}
  end

  def withdraw(%Transaction{receiver: user, amount: amount, currency: currency}) do
    :ets.lookup(__MODULE__, {user, currency})
    |> withdraw(amount)
  end

  def withdraw([], amount), do: {:error, :not_enough_money}

  def withdraw([{key, balance}], amount) when amount > balance, do: {:error, :not_enough_money}

  def withdraw([{key, balance}], amount) do
    new_balance = balance - amount
    :ets.insert(__MODULE__, {key, new_balance})

    {:ok, new_balance}
  end

  def get_balance(%Transaction{receiver: user, currency: currency}) do
    :ets.lookup(__MODULE__, {user, currency})
    |> get_balance()
  end

  def get_balance([]), do: {:ok, 0}

  def get_balance([{key, balance}]), do: {:ok, balance}

  def send_amount(%Transaction{currency: currency, sender: user} = transaction) do
    :ets.lookup(__MODULE__, {user, currency})
    |> send_amount(transaction)
  end

  def send_amount([], _), do: {:error, :not_enough_money}

  def send_amount([{key, balance}], %Transaction{amount: amount}) when amount > balance,
    do: {:error, :not_enough_money}

  def send_amount([{key, balance}], %Transaction{amount: amount} = transaction) do
    new_balance = balance - amount
    :ets.insert(__MODULE__, {key, new_balance})
    {:ok, receiver_balance} = ExBanking.User.make_transaction(%{transaction | type: :deposit})

    {:ok, new_balance, receiver_balance}
  end
end
