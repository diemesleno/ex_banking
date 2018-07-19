defmodule ExBanking.Transaction do
  @moduledoc """
  The %Transaction{} struct validates
  that it is a valid transaction
  """
  @type transaction :: Transaction.t()

  alias ExBanking.Transaction
  defstruct [:type, :receiver, :sender, :amount, :currency]
  defguard are_binaries(value1, value2) when is_binary(value1) and is_binary(value2)

  defguard are_binaries(value1, value2, value3)
           when is_binary(value1) and is_binary(value2) and is_binary(value3)

  @doc """
  It returns a `transaction()` if it's valid
  """
  @spec new(type :: atom(), user :: binary(), amount :: number(), currency :: binary()) ::
          transaction()
  def new(type, user, amount, currency) when are_binaries(user, currency) do
    with true <- user_exists?(user),
         {:ok, correct_amount} <- format_amount(amount),
         do: %Transaction{
           type: type,
           receiver: user,
           amount: correct_amount,
           currency: currency
         }
  end

  def new(_, _, _, _), do: {:error, :wrong_arguments}

  @doc """
  It returns a `balance`
  """
  @spec new(:balance, user :: binary(), currency :: binary) :: transaction()
  def new(:balance, user, currency) when are_binaries(user, currency) do
    with true <- user_exists?(user),
         do: %Transaction{
           type: :balance,
           receiver: user,
           currency: currency
         }
  end

  def new(_, _, _), do: {:error, :wrong_arguments}

  @doc """
  It returns a `send`
  """
  @spec new(
          :send,
          from_user :: binary(),
          to_user :: binary(),
          amount :: number(),
          currency :: binary()
        ) :: transaction()
  def new(:send, from_user, to_user, amount, currency)
      when are_binaries(from_user, to_user, currency) do
    with true <- sender_exists?(from_user),
         true <- receiver_exists?(to_user),
         {:ok, correct_amount} <- format_amount(amount),
         do: %Transaction{
           type: :send,
           receiver: to_user,
           sender: from_user,
           currency: currency,
           amount: correct_amount
         }
  end

  def new(_, _, _, _, _), do: {:error, :wrong_arguments}

  defp format_amount(amount) when is_number(amount) and amount > 0 do
    {:ok, Money.convert_to_integer(amount)}
  end

  defp format_amount(_), do: {:error, :wrong_arguments}

  defp exists?(name) when is_binary(name) do
    #If the user does not exist, cannot start in the supervisor
    sup_available =
      ExBanking.User.Supervisor.exists?(name)
      |> ExBanking.User.Supervisor.can_start?()

    not sup_available
  end

  defp user_exists?(name) when is_binary(name) do
    name
    |> exists?()
    |> user_exists?()
  end

  defp user_exists?(true), do: true
  defp user_exists?(false), do: {:error, :user_does_not_exists}

  defp sender_exists?(user) when is_binary(user) do
    user
    |> exists?
    |> sender_exists?
  end

  defp sender_exists?(true), do: true
  defp sender_exists?(false), do: {:error, :sender_does_not_exists}

  defp receiver_exists?(user) when is_binary(user) do
    user
    |> exists?
    |> receiver_exists?
  end

  defp receiver_exists?(true), do: true
  defp receiver_exists?(false), do: {:error, :receiver_does_not_exists}
end
