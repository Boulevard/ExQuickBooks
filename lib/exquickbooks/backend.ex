defmodule ExQuickBooks.Backend do
  @moduledoc false

  # The request/response format is compatible with HTTPoison.
  @type method :: atom
  @type url :: binary
  @type body :: binary
  @type headers :: [{binary, binary}]
  @type options :: Keyword.t
  @type response :: {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}

  @callback request(method, url, body, headers, options) :: response
end
