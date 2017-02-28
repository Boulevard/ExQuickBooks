defmodule QuickBooks.EndpointTest do
  use ExUnit.Case, async: false

  doctest QuickBooks.Endpoint

  defmodule FooEndpoint do
    use QuickBooks.Endpoint
  end

  setup do
    Application.put_env(:quickbooks, :consumer_key, "key")
    Application.put_env(:quickbooks, :consumer_secret, "secret")
  end

  test "request/5 signs the request" do
    FooEndpoint.request(:get, "foo")

    assert_received {:mocked_request, %{
      headers: [{"Authorization", "OAuth " <> _}]
    }}
  end

  test "request/5 preserves body" do
    FooEndpoint.request(:get, "foo", "bar")
    assert_received {:mocked_request, %{body: "bar"}}
  end

  test "request/5 preserves options" do
    options = [
      params: [{"foo", "bar"}]
    ]

    FooEndpoint.request(:get, "foo", nil, nil, options)

    assert_received {:mocked_request, %{
      options: ^options
    }}
  end

  test "request/5 preserves extra headers" do
    extra_headers = [{"X-Leo", "is handsome and cool"}]

    FooEndpoint.request(:get, "foo", nil, extra_headers)

    assert_received {:mocked_request, %{
      headers: [_ | ^extra_headers]
    }}
  end
end
