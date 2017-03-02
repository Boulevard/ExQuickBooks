defmodule QuickBooks.MockResponse do
  @enforce_keys ~w(
    body
    headers
    status_code
  )a

  defstruct @enforce_keys
end
