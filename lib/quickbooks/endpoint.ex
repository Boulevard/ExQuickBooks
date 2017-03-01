defmodule QuickBooks.Endpoint do
  @moduledoc false
  @default_using_options [base_url: ""]

  defmacro __using__(using_options \\ []) do
    merged_using_options = Keyword.merge(@default_using_options, using_options)

    quote do
      def request(method, url, body \\ "", headers \\ [], options \\ []) do
        endpoint = unquote(__MODULE__)
        use_options = unquote(merged_using_options)

        endpoint.request(method, url, body, headers, options, use_options)
      end

      def get(url, body \\ "", headers \\ [], options \\ []) do
        request(:get, url, body, headers, options)
      end

      def post(url, body \\ "", headers \\ [], options \\ []) do
        request(:post, url, body, headers, options)
      end

      def put(url, body \\ "", headers \\ [], options \\ []) do
        request(:put, url, body, headers, options)
      end

      def patch(url, body \\ "", headers \\ [], options \\ []) do
        request(:patch, url, body, headers, options)
      end

      def delete(url, body \\ "", headers \\ [], options \\ []) do
        request(:delete, url, body, headers, options)
      end

      def head(url, body \\ "", headers \\ [], options \\ []) do
        request(:head, url, body, headers, options)
      end

      def options(url, body \\ "", headers \\ [], options \\ []) do
        request(:options, url, body, headers, options)
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end

  def request(method, url, body, headers, options, use_options) do
    full_url = use_options[:base_url] <> url

    {header, new_params} = sign(method, full_url, options[:params] || [])

    new_headers = [header] ++ headers
    new_options = Keyword.put(options, :params, new_params)

    QuickBooks.backend.request(method, full_url, body, new_headers, new_options)
  end

  defp sign(method, url, params) do
    method
    |> to_string
    |> OAuther.sign(url, params, credentials())
    |> OAuther.header
  end

  defp credentials do
    QuickBooks.credentials
    |> OAuther.credentials
  end
end
