defmodule QuickBooks.Endpoint do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use unquote(QuickBooks.backend)

      def request(method, url, body \\ "", headers \\ [], options \\ []) do
        params = options[:params] || []

        credentials =
          QuickBooks.credentials
          |> OAuther.credentials

        {header, new_params} =
          OAuther.sign(to_string(method), process_url(url), params, credentials)
          |> OAuther.header

        new_headers = [header] ++ headers
        new_options = Keyword.put(options, :params, new_params)

        super(method, url, body, new_headers, new_options)
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
