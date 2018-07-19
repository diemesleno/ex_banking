defmodule ExBanking do
  @moduledoc """
  This module makes all the users transactions.
  """
  alias ExBanking.User
  alias ExBanking.Transaction
  alias ExBanking.Format

  @type banking_error ::
          {:error,
           :wrong_arguments
           | :user_already_exists
           | :user_does_not_exist
           | :not_enough_money
           | :sender_does_not_exist
           | :receiver_does_not_exist
           | :too_many_requests_to_user
           | :too_many_requests_to_sender
           | :too_many_requests_to_receiver}

  @type banking_response ::
          :ok
          | {:ok, new_balance :: number}
          | {:ok, from_user_balance :: number, to_user_balance :: number}

  @doc """
  It creates new user in the system with
  0 balance of any currency
  """
  @spec create_user(user :: String.t()) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    ExBanking.User.Supervisor.create_user(user)
  end

  def create_user(_), do: {:error, :wrong_arguments}

  @doc """
  It increases user's balance in given currency 
  by amount value and returns new_balance
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) do
    case Transaction.new(:deposit, user, amount, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)
        |> Format.response()

      error ->
        error
    end
  end

  @doc """
  It decreases user's balance in given currency 
  by amount value and returns new_balance
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
    case Transaction.new(:withdraw, user, amount, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)
        |> Format.response()

      error ->
        error
    end
  end

  @doc """
  It returns balance of the user
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | banking_error
  def get_balance(user, currency) do
    case Transaction.new(:balance, user, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)
        |> Format.response()

      error ->
        error
    end
  end

  @doc """
  It decreases from_user's balance in given currency 
  by amount value and also increases to_user's balance 
  in given currency by amount value and returns the user balance
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  def send(from_user, to_user, amount, currency) do
    case Transaction.new(:send, from_user, to_user, amount, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)
        |> Format.response()

      error ->
        error
    end
  end
end
