defmodule Lonely.Result.List do
  @moduledoc """
  Functions to operate on result lists.
  """

  alias Lonely.Result

  @type t :: Result.t

  @doc """
  Combines a list of results into a result with a list of values. If there is
  any error, the first is returned.

      iex> import Lonely.Result.List
      ...> combine([])
      {:ok, []}

      iex> import Lonely.Result.List
      ...> combine([{:ok, 1}, {:ok, 2}, {:ok, 3}])
      {:ok, [1, 2, 3]}

      iex> import Lonely.Result.List
      ...> combine([{:ok, 1}, {:error, 2}, {:ok, 3}])
      {:error, 2}

      iex> import Lonely.Result.List
      ...> combine([{:ok, 1}, {:error, 2}, {:error, 3}])
      {:error, 2}
  """
  @spec combine([t]) :: t
  def combine(xs) do
    xs
    |> Enum.reduce_while({:ok, []}, &combine_reducer/2)
    |> Result.map(&Enum.reverse/1)
  end

  defp combine_reducer(a = {:ok, _}, acc), do:
    {:cont, cons(a, acc)}
  defp combine_reducer(error, _), do:
    {:halt, error}

  @doc """
  Cons cell.

      iex> import Lonely.Result.List
      ...> cons({:ok, 1}, {:ok, []})
      {:ok, [1]}

      iex> import Lonely.Result.List
      ...> cons({:error, :boom}, {:ok, []})
      {:error, :boom}

      iex> import Lonely.Result.List
      ...> cons({:ok, 1}, {:error, :boom})
      {:error, :boom}
  """
  def cons({:ok, x}, {:ok, xs}) when is_list(xs), do:
    {:ok, [x | xs]}
  def cons({:ok, _}, e = {:error, _}), do: e
  def cons(e = {:error, _}, _), do: e

  @doc """
  Splits a result list into a list of results.

      iex> import Lonely.Result.List
      ...> split({:ok, []})
      []

      iex> import Lonely.Result.List
      ...> split({:ok, [1]})
      [{:ok, 1}]

      iex> import Lonely.Result.List
      ...> split({:ok, [1, 2]})
      [{:ok, 1}, {:ok, 2}]

      iex> import Lonely.Result.List
      ...> split({:error, :boom})
      {:error, :boom}
  """
  @spec split(t) :: [t]
  def split({:ok, []}), do: []
  def split({:ok, xs}) when is_list(xs), do:
    Enum.map(xs, &({:ok, &1}))
  def split(e = {:error, _}), do: e
end
