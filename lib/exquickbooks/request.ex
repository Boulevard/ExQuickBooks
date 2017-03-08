defmodule ExQuickBooks.Request do
  @moduledoc false

  @enforce_keys [
    :method,
    :url,
    :body,
    :headers,
    :options
  ]

  # The request format is directly compatible with HTTPoison.
  @type t :: %__MODULE__{
    method:   atom,
    url:      binary,
    body:     binary,
    headers:  [{binary, binary}],
    options:  Keyword.t
  }
  defstruct @enforce_keys
end
