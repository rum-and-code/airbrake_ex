defmodule AirbrakeEx do
  @moduledoc """
  This module provides functions to report any kind of exception to
  [Airbrake](https://airbrake.io/).

  ### Configuration

  The `project_key` and `project_id` parameters must be set
  in your application environment, usually defined in your `config/config.exs` or,
  if you are setting them with environment variables, then wherever you do that
  (`config/runtime.exs`, `rel/config.exs`, etc). `logger_level` and `environment` are optional.
  To use an [Errbit](https://github.com/errbit/errbit) instance rather than Airbrake, set
  `:endpoint` to your custom url.

  ```elixir
  config :airbrake_ex,
    project_key: "abcdef12345",
    project_id: 123456,
    logger_level: :error,
    environment: Mix.env,
    endpoint: "http://errbit.yourdomain.com"
  ```

  ## Usage

  ```elixir
  try do
    IO.inspect("test",[],"")
  rescue
    exception -> AirbrakeEx.notify(exception, __STACKTRACE__)
  end
  ```

  You can ignore certain types of errors by specifying the `:ignore` config key:

  ```elixir
  config :airbrake_ex,
    ...
    # List form
    ignore: [Phoenix.Router.NoRouteError]
    # OR
    # Function
    ignore: fn(error) ->
      cond do
        error.type == Phoenix.Router.NoRouteError -> true
        String.contains?(error.message, "Ecto.NoResultsError") -> true
        true -> false
      end
    end
  ```
  """

  alias AirbrakeEx.{ExceptionParser, Notifier}

  @doc """
  Notify `airbrake` about a new exception

  ## Parameters

    - exception: Exception to notify
    - stacktrace: the __STACKTRACE__ from the catch/rescue block
    - options: Options

  ## Options

  Options that are sent to `airbrake` with exceptions:

    - context
    - session
    - params
    - environment
  """
  def notify(exception, stacktrace \\ [], options \\ []) do
    exception
    |> ExceptionParser.parse(stacktrace)
    |> Notifier.notify(options)
  end
end
