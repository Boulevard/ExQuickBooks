defmodule ExQuickBooks.MockRequest do
  @enforce_keys ~w(
    method
    url
    body
    headers
    options
  )a

  defstruct @enforce_keys
end
