defmodule Lonely.Result do
  @moduledoc """
  Composes the tuples `{:ok, a}` and `{:error, e}` as the type `Result.t`.

  It is common to get either a value or `nil`. A way to apply a function to
  a value letting `nil` untouched.
  The following example will return `20` when `n = 2` and `nil` when `n > 3`.

      import Lonely.Result

      [1, 2, 3]
      |> Enum.find(fn x -> x == n end)
      |> wrap()
      |> map(fn x -> x * 10 end)
      |> unwrap()

  Some functions return `{:ok, a}` or `:error`. The next example uses `wrap/1`
  to normalise it to a result tagging the error appropriately.
  The following example will return `30` when `i = 2` and `:out_of_bounds`
  when `i > 2`.

      import Lonely.Result

      [1, 2, 3]
      |> Enum.fetch(i)
      |> wrap(with: :out_of_bounds)
      |> map(fn x -> x * 10 end)
      |> unwrap()

  Some other times you are certain you will be receiving a result so you can
  leave out `wrap/1` and just map over the value. Also, you might want to
  recover from the error.

      iex> import Lonely.Result
      ...> str = "23:50:07"
      ...> Time.from_iso8601(str)
      ...> |> map(&Time.to_erl/1)
      ...> |> flat_map_error(fn
      ...>   :invalid_format -> {:ok, {0, 0, 0}}
      ...>   reason -> {:error, {reason, str}}
      ...> end)
      {:ok, {23, 50, 7}}

      iex> import Lonely.Result
      ...> str = "10:11:61"
      ...> Time.from_iso8601(str)
      ...> |> map(&Time.to_erl/1)
      ...> |> flat_map_error(fn
      ...>   :invalid_format -> {:ok, {0, 0, 0}}
      ...>   reason -> {:error, {reason, str}}
      ...> end)
      {:error, {:invalid_time, "10:11:61"}}
  """

  @typep a :: any
  @typep b :: any
  @typep e :: any

  @typedoc """
  Result type.
  """
  @type t :: {:ok, a} | {:error, e}

  @doc """
  Maps an ok value over a function.

  ### Identity

      iex> import Lonely.Result
      ...> map({:ok, 1}, &(&1))
      {:ok, 1}

      iex> import Lonely.Result
      ...> map({:error, :boom}, &(&1))
      {:error, :boom}

  ### Composition

      iex> import Lonely.Result
      ...> f = fn x -> x + x end
      ...> g = fn x -> x - x end
      ...> {:ok, 1}
      ...> |> map(f)
      ...> |> map(g)
      {:ok, 0}

      iex> import Lonely.Result
      ...> f = fn x -> x + x end
      ...> g = fn x -> x - x end
      ...> fg = &(&1 |> f.() |> g.())
      ...> map({:ok, 1}, fg)
      {:ok, 0}

  ## Applicative

      iex> import Lonely.Result
      ...> a = {:ok, 1}
      ...> f = {:ok, fn x -> x + x end}
      ...> map(a, f)
      {:ok, 2}

      iex> import Lonely.Result
      ...> e = {:error, :boom}
      ...> f = {:ok, fn x -> x + x end}
      ...> map(e, f)
      {:error, :boom}

      iex> import Lonely.Result
      ...> a = {:ok, 1}
      ...> e = {:error, :boom}
      ...> map(a, e)
      {:error, :boom}
  """
  @spec map(t, {:ok, (a -> b)}) :: t
  def map({:ok, a}, {:ok, f}), do:
    {:ok, f.(a)}
  def map({:ok, _}, e = {:error, _}), do: e

  @spec map(t, (a -> b)) :: t
  def map({:ok, a}, f), do:
    {:ok, f.(a)}
  def map(e = {:error, _}, _f), do: e

  @doc """
  Maps an error value over function.

      iex> import Lonely.Result
      ...> map_error({:ok, 1}, fn x -> to_string(x) end)
      {:ok, 1}

      iex> import Lonely.Result
      ...> map_error({:error, :boom}, fn x -> to_string(x) end)
      {:error, "boom"}
  """
  @spec map_error(t, (a -> b)) :: t
  def map_error(a = {:ok, _}, _f), do: a
  def map_error({:error, e}, f), do:
    {:error, f.(e)}

  @doc """
  Maps an ok value over a function and flattens the resulting value into a
  single result.

      iex> import Lonely.Result
      ...> flat_map({:ok, 1}, fn x -> {:ok, x} end)
      {:ok, 1}

      iex> import Lonely.Result
      ...> flat_map({:error, :boom}, fn x -> {:ok, x} end)
      {:error, :boom}
  """
  @spec flat_map(t, (a -> t)) :: t
  def flat_map({:ok, a}, f), do:
    f.(a)
  def flat_map(e = {:error, _}, _f), do: e

  @doc """
  Maps an error value over function.

      iex> import Lonely.Result
      ...> flat_map_error({:ok, 1}, fn x -> to_string(x) end)
      {:ok, 1}

      iex> import Lonely.Result
      ...> flat_map_error({:error, :boom}, fn _ -> {:ok, -1} end)
      {:ok, -1}
  """
  @spec flat_map_error(t, (a -> b)) :: t
  def flat_map_error(a = {:ok, _}, _f), do: a
  def flat_map_error({:error, e}, f), do:
    f.(e)

  @doc """
  Checks if the result is ok.

      iex> import Lonely.Result
      ...> is_ok({:ok, 1})
      true

      iex> import Lonely.Result
      ...> is_ok({:error, 1})
      false
  """
  @spec is_ok(t) :: boolean
  def is_ok({:ok, _}), do: true
  def is_ok({:error, _}), do: false

  @doc """
  Checks if the result is an error.

      iex> import Lonely.Result
      ...> is_error({:ok, 1})
      false

      iex> import Lonely.Result
      ...> is_error({:error, 1})
      true
  """
  @spec is_error(t) :: boolean
  def is_error(a), do: !is_ok(a)

  @doc """
  Wraps a value into a result.

      iex> import Lonely.Result
      ...> wrap(nil)
      {:error, nil}

      iex> import Lonely.Result
      ...> wrap({:error, :boom})
      {:error, :boom}

      iex> import Lonely.Result
      ...> wrap({:ok, 1})
      {:ok, 1}

      iex> import Lonely.Result
      ...> wrap(1)
      {:ok, 1}
  """
  @spec wrap(a) :: t
  def wrap(nil), do: {:error, nil}
  def wrap(:error), do: {:error, nil}
  def wrap(e = {:error, _}), do: e
  def wrap(a = {:ok, _}), do: a
  def wrap(a), do: {:ok, a}

  @doc """
  Wraps a value into a result or use the provided error instead of `nil`.

      iex> import Lonely.Result
      ...> wrap(nil, with: :boom)
      {:error, :boom}
  """
  @spec wrap(a, with: e) :: t
  def wrap(nil, with: e), do: {:error, e}
  def wrap(:error, with: e), do: {:error, e}
  def wrap(a, with: _), do: wrap(a)

  @doc """
  Returns the value of the result.

  If you want to raise the error, use `unwrap!/1`.

      iex> import Lonely.Result
      ...> unwrap({:ok, 1})
      1

      iex> import Lonely.Result
      ...> unwrap({:error, :boom})
      :boom
  """
  @spec unwrap(t) :: a
  def unwrap({_, x}), do: x

  @doc """
  Returns the value of an ok result or raises the error.

      iex> import Lonely.Result
      ...> unwrap!({:ok, 1})
      1

      iex> import Lonely.Result
      ...> assert_raise(RuntimeError, "boom", fn -> unwrap!({:error, "boom"}) end)
      %RuntimeError{message: "boom"}
  """
  @spec unwrap!(t) :: a
  def unwrap!({:ok, a}), do: a
  def unwrap!({:error, e}), do: raise e

  @doc """
  Combines a list of results into a result with a list of values. If there is
  any error, the first is returned.

      iex> import Lonely.Result
      ...> combine([])
      {:ok, []}

      iex> import Lonely.Result
      ...> combine([{:ok, 1}, {:ok, 2}, {:ok, 3}])
      {:ok, [1, 2, 3]}

      iex> import Lonely.Result
      ...> combine([{:ok, 1}, {:error, 2}, {:ok, 3}])
      {:error, 2}

      iex> import Lonely.Result
      ...> combine([{:ok, 1}, {:error, 2}, {:error, 3}])
      {:error, 2}
  """
  @spec combine([t]) :: t
  def combine(xs) do
    xs
    |> Enum.reduce_while({:ok, []}, &combine_reducer/2)
    |> map(&Enum.reverse/1)
  end

  defp combine_reducer(a = {:ok, _}, acc), do:
    {:cont, cons(a, acc)}
  defp combine_reducer(error, _), do:
    {:halt, error}

  @doc """
  Cons cell.

      iex> import Lonely.Result
      ...> cons({:ok, 1}, {:ok, []})
      {:ok, [1]}

      iex> import Lonely.Result
      ...> cons({:error, :boom}, {:ok, []})
      {:error, :boom}

      iex> import Lonely.Result
      ...> cons({:ok, 1}, {:error, :boom})
      {:error, :boom}
  """
  def cons({:ok, x}, {:ok, xs}) when is_list(xs), do:
    {:ok, [x | xs]}
  def cons({:ok, _}, e = {:error, _}), do: e
  def cons(e = {:error, _}, _), do: e

  @doc """
  Splits a result list into a list of results.

      iex> import Lonely.Result
      ...> split({:ok, []})
      []

      iex> import Lonely.Result
      ...> split({:ok, [1]})
      [{:ok, 1}]

      iex> import Lonely.Result
      ...> split({:ok, [1, 2]})
      [{:ok, 1}, {:ok, 2}]

      iex> import Lonely.Result
      ...> split({:error, :boom})
      {:error, :boom}
  """
  @spec split(t) :: [t]
  def split({:ok, []}), do: []
  def split({:ok, xs}) when is_list(xs), do:
    Enum.map(xs, &({:ok, &1}))
  def split(e = {:error, _}), do: e
end
