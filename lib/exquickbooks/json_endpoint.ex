defmodule ExQuickBooks.JSONEndpoint do
  @moduledoc false

  import ExQuickBooks.Endpoint, only: [
    merge_headers: 2,
    send_request: 1
  ]

  @json_headers [
    {"Accept", "application/json"},
    {"Content-Type", "application/json"}
  ]

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [
        send_json_request: 1
      ]

      @type json_map :: %{required(String.t) => any}
    end
  end

  def send_json_request(request) do
    new_headers = merge_headers(@json_headers, request.headers)
    new_request = %{request | headers: new_headers}

    with {:ok, response} <- send_request(new_request) do
      Poison.Parser.parse(response.body)
    end
  end
end
