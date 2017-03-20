defmodule ExQuickBooks.Endpoint.JSON do
  @moduledoc false

  import ExQuickBooks.Endpoint, only: [
    merge_headers: 2,
    send_request: 1
  ]

  alias ExQuickBooks.Request
  alias HTTPoison.Response

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

  def send_json_request(request = %Request{}) do
    new_body = encode_body(request.body)
    new_headers = merge_headers(@json_headers, request.headers)

    %{request | body: new_body, headers: new_headers}
    |> send_request
    |> parse_response
  end

  defp encode_body(body) when is_binary(body) do
    body
  end
  defp encode_body(body) do
    Poison.Encoder.encode(body, [])
  end

  defp parse_response({ok_error, response = %Response{}}) do
    is_json =
      response
      |> parse_content_type
      |> String.starts_with?("application/json")

    if is_json do
      {ok_error, Poison.Parser.parse!(response.body)}
    else
      {ok_error, response}
    end
  end
  defp parse_response(non_response_result) do
    non_response_result
  end

  defp parse_content_type(%Response{headers: headers}) do
    Enum.find_value(headers, "text/plain", fn({header, value}) ->
      if String.downcase(header) == "content-type", do: value
    end)
  end
end
