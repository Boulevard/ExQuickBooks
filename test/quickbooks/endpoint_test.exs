defmodule QuickBooks.EndpointTest do
  use ExUnit.Case, async: false
  alias QuickBooks.Endpoint

  doctest Endpoint

  defmodule TestEndpoint do
    use Endpoint, base_url: "http://localhost/"
  end

  setup do
    Application.put_env(:quickbooks, :consumer_key, "key")
    Application.put_env(:quickbooks, :consumer_secret, "secret")
  end

  test "request/5 prepends the base URL" do
    TestEndpoint.request(:get, "foo")

    assert_received {:mocked_request, %{
      url: "http://localhost/" <> _
    }}
  end

  test "request/5 signs the request" do
    TestEndpoint.request(:get, "foo")

    assert_received {:mocked_request, %{
      headers: [{"Authorization", "OAuth " <> _}]
    }}
  end

  test "request/5 preserves body" do
    TestEndpoint.request(:post, "foo", "bar")
    assert_received {:mocked_request, %{body: "bar"}}
  end

  test "request/5 preserves options" do
    options = [
      params: [{"foo", "bar"}]
    ]

    TestEndpoint.request(:get, "foo", nil, nil, options)

    assert_received {:mocked_request, %{
      options: ^options
    }}
  end

  test "request/5 preserves extra headers" do
    extra_headers = [{"X-Leo", "is handsome and cool"}]

    TestEndpoint.request(:get, "foo", nil, extra_headers)

    assert_received {:mocked_request, %{
      headers: [_ | ^extra_headers]
    }}
  end
end
