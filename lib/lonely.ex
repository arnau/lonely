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
      2

  Some other times you are certain you will be receiving a result so you can
  leave out `wrap/1` and just map over the value. Also, you might want to
  recover from the error.

      iex> import Lonely.Result
      ...> str = ""
      ...> Time.from_iso8601(str)
      ...> |> map(&Time.to_erl/1)
      ...> |> flat_map_error(fn
      ...>   :invalid_format -> {:ok, {0, 0, 0}}
      ...>   reason -> {:error, {reason, str}}
      ...> end)
      {:ok, {0, 0, 0}}

  Check the `Lonely.Result` module for more examples.
  """
end
