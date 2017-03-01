defmodule QuickBooks.MockBackend do
  @moduledoc false
  @behaviour QuickBooks.Backend

  def request(method, url, body, headers, options) do
    send self(), {:mocked_request, %{
      method: method,
      url: url,
      body: body,
      headers: headers,
      options: options
    }}

    %HTTPoison.Response{
      body: "",
      headers: [],
      status_code: 200
    }
  end
end
