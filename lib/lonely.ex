defmodule Lonely do
  @moduledoc """
  Lonely. Helpers to pipe through results `{:ok, a} | {:error, e}`.

  It is common to get either a value or `nil`. A way to apply a function to
  a value letting `nil` untouched.

      iex> alias Lonely.Result
      ...> [1, 2, 3]
      ...> |> Enum.find(fn x -> x == 2 end)
      ...> |> Result.wrap()
      ...> |> Result.map(fn x -> x * 10 end)
      ...> |> Result.unwrap()
      20

  Some other times you are certain you will be receiving a result so you can
  leave out `wrap/1` and just map over the value. Also, you might want to
  recover from the error.

      iex> alias Lonely.Result
      ...> str = ""
      ...> Time.from_iso8601(str)
      ...> |> Result.map(&Time.to_erl/1)
      ...> |> Result.flat_map_error(fn
      ...>   :invalid_format -> {:ok, {0, 0, 0}}
      ...>   reason -> {:error, {reason, str}}
      ...> end)
      {:ok, {0, 0, 0}}

  Check the `Lonely.Result` module for more examples.

  Sometimes you can't be bothered by wrapping a value in a result. You can
  then just map over values that could be `nil`:

      iex> alias Lonely.Option
      ...> [1, 2, 3]
      ...> |> Enum.find(fn x -> x == 2 end)
      ...> |> Option.map(fn x -> x * 10 end)
      20

      iex> alias Lonely.Option
      ...> [1, 2, 3]
      ...> |> Enum.find(fn x -> x == 10 end)
      ...> |> Option.map(fn x -> x * 10 end)
      ...> |> Option.with_default(0)
      0
  """
end
