defmodule QuickBooks.HTTPoisonBackend do
  @moduledoc false
  @behaviour QuickBooks.Backend

  defdelegate request(method, url, body, headers, options), to: HTTPoison
end
