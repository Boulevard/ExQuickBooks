defmodule ExQuickBooks.JSONEndpointTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase
  use ExQuickBooks.Endpoint, base_url: "http://localhost/"
  use ExQuickBooks.JSONEndpoint

  doctest ExQuickBooks.JSONEndpoint

  test "send_json_request/1 sets appropriate headers" do
    request(:get, "path") |> send_json_request

    assert %{
      headers: [
        {"Accept", "application/json" <> _},
        {"Content-Type", "application/json" <> _}
      ]
    } = take_request()
  end

  test "send_json_request/1 doesn't overwrite existing headers" do
    headers = [
      {"Accept", "application/x-shockwave-flash"},
      {"Content-Type", "application/vnd.ms-excel"}
    ]

    request(:get, "path", nil, headers) |> send_json_request

    assert %{
      headers: ^headers
    } = take_request()
  end

  test "send_json_request/1 parses the JSON response" do
    send_response %HTTPoison.Response{
      body: ~S({"foo": true}),
      headers: [{"Content-Type", "application/json"}],
      status_code: 200
    }

    result =
      request(:get, "path")
      |> send_json_request

    assert result == {:ok, %{"foo" => true}}
  end
end
