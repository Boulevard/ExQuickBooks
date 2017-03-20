defmodule ExQuickBooks.Backend.HTTPoison do
  @moduledoc false
  @behaviour ExQuickBooks.Backend

  alias ExQuickBooks.Request

  def request(request = %Request{}) do
    HTTPoison.request(
      request.method,
      request.url,
      request.body,
      request.headers,
      request.options
    )
  end
end
