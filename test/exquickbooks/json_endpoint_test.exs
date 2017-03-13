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

  test "send_json_request/1 encodes non-binary request bodies" do
    request(:get, "path", %{foo: true}) |> send_json_request

    # Note that IO lists are also accepted.
    assert %{body: body} = take_request()
    assert to_string(body) == ~S({"foo":true})
  end

  test "send_json_request/1 doesn't encode binary request bodies" do
    request(:get, "path", "foo") |> send_json_request

    assert %{
      body: "foo"
    } = take_request()
  end

  test "send_json_request/1 parses JSON responses" do
    send_response %HTTPoison.Response{
      body: ~S({"foo": true}),
      headers: [{"Content-Type", "application/json"}],
      status_code: 200
    }

    assert {:ok, %{"foo" => true}} =
      request(:get, "path") |> send_json_request
  end

  test "send_json_request/1 parses JSON error responses" do
    send_response %HTTPoison.Response{
      body: ~S({"foo": true}),
      headers: [{"Content-Type", "application/json"}],
      status_code: 400
    }

    assert {:error, %{"foo" => true}} =
      request(:get, "path") |> send_json_request
  end

  test "send_json_request/1 doesn't parse non-JSON responses" do
    send_response %HTTPoison.Response{
      body: "foo",
      headers: [{"Content-Type", "text/plain"}],
      status_code: 200
    }

    assert {:ok, %HTTPoison.Response{body: "foo"}} =
      request(:get, "path") |> send_json_request
  end
end
