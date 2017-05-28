defmodule Lonely.Option do
  @moduledoc """
  Handles any value that could be `nil` as well.
  """

  alias Lonely.Result

  @typedoc """
  Option type.
  """
  @type t :: any | nil

  @doc """
  Maps an option over a function.

      iex> import Lonely.Option
      ...> map(1, fn x -> x + x end)
      2

      iex> import Lonely.Option
      ...> map(nil, fn x -> x + x end)
      nil
  """
  @spec map(t, (any -> t)) :: t
  def map(nil, _f), do: nil
  def map(a, f), do: f.(a)

  @doc """
  Transforms an Option into a Result.

      iex> import Lonely.Option
      ...> to_result(1, :boom)
      {:ok, 1}

      iex> import Lonely.Option
      ...> to_result(nil, :boom)
      {:error, :boom}
 """
  @spec to_result(t, any) :: Result.t
  def to_result(nil, reason), do:
    {:error, reason}
  def to_result(a, _reason), do:
    {:ok, a}
end
