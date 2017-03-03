defmodule ExQuickBooks.HTTPoisonBackend do
  @moduledoc false
  @behaviour ExQuickBooks.Backend

  defdelegate request(method, url, body, headers, options), to: HTTPoison
end
