defmodule Lonely.Option do
  @moduledoc """
  Handles any value that could be `nil` as well.

  Some functions result in either the value or just `nil`. For these ocasions
  you can either transform it to a result with `Lonely.Result.wrap/1` or
  use this module.

      iex> import Lonely.Option
      ...> [1, 2, 3]
      ...> |> Enum.find(fn x -> x == 2 end)
      ...> |> map(fn x -> x * 10 end)
      20

      iex> import Lonely.Option
      ...> [1, 2, 3]
      ...> |> Enum.find(fn x -> x == 10 end)
      ...> |> map(fn x -> x * 10 end)
      nil
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
  Maps an option over a function or uses the provided default.

      iex> import Lonely.Option
      ...> map_or(1, fn x -> x + x end, 0)
      2

      iex> import Lonely.Option
      ...> map_or(nil, fn x -> x + x end, 0)
      0
  """
  @spec map_or(t, (any -> t), any) :: t
  def map_or(nil, _f, default), do: default
  def map_or(a, f, _), do: f.(a)

  @doc """
  Filters a value and maps it over a function.

      iex> import Lonely.Option
      ...> filter_map(1, fn x -> x > 0 end, fn x -> x + x end)
      2

      iex> import Lonely.Option
      ...> filter_map(-1, fn x -> x > 0 end, fn x -> x + x end)
      -1

      iex> import Lonely.Option
      ...> filter_map(nil, fn x -> x > 0 end, fn x -> x + x end)
      nil
  """
  @spec filter_map(t, (any -> boolean), (any -> t)) :: t
  def filter_map(nil, _f, _g), do: nil
  def filter_map(a, f, g) do
    if f.(a), do: g.(a), else: a
  end

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

  @doc """
  Uses the default if `nil`.

      iex> import Lonely.Option
      ...> with_default(1, 0)
      1

      iex> import Lonely.Option
      ...> with_default(nil, 0)
      0
  """
  @spec with_default(t, any) :: any
  def with_default(nil, default), do: default
  def with_default(a, _), do: a
end
