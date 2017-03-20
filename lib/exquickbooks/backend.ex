defmodule ExQuickBooks.Backend do
  @moduledoc false

  alias ExQuickBooks.Backend.Request
  alias HTTPoison.Error
  alias HTTPoison.Response

  @callback request(Request.t) :: {:ok, Response.t} | {:error, Error.t}
end
