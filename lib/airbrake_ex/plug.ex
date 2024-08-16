defmodule AirbrakeEx.Plug do
  @moduledoc """
  Add the `AirbrakeEx.Plug` to you web application Plug stack
  to send all exceptions to `airbrake`

  ```elixir
  defmodule YourApp.Router do
    use Phoenix.Router
    use AirbrakeEx.Plug

    # ...
  end
  ```
  """

  alias AirbrakeEx.{ExceptionParser, Notifier}

  defmacro __using__(_env) do
    quote location: :keep do
      @before_compile AirbrakeEx.Plug
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable call: 2

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            parsed_exception = ExceptionParser.parse(exception, __STACKTRACE__)
            session = Map.get(conn.private, :plug_session)

            _ =
              Notifier.notify(
                parsed_exception,
                params: conn.params,
                session: session,
                context: %{url: Plug.Conn.request_url(conn)}
              )

            reraise exception, __STACKTRACE__
        end
      end
    end
  end
end
