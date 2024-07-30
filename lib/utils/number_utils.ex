
defmodule BulmaWidgets.Utils.NumberParse do
  require Logger

  @moduledoc """
  Module to do simple number parsing based on best effort,
  first as float, then integer, otherwise string.
  """

  def menu_event_parse_number(value, _event) do
    {:ok, number_parse(value)}
  end

  def number_parse(numstr, :float) do
    case Float.parse(numstr) do
      {num, _rem} -> num
      :error -> numstr
    end
  end

  def number_parse("0x" <> numstr, :integer) do
    case Integer.parse(numstr, 16) do
      {num, ""} -> num
      # {numstr, _rem} -> number_parse(numstr, :float)
      :error -> number_parse(numstr, :float)
    end
  end

  def number_parse(numstr, :integer) do
    case Integer.parse(numstr) do
      {num, ""} -> num
      # {num, _rem} -> number_parse(numstr, :float)
      :error -> number_parse(numstr, :float)
    end
  end

  def number_parse(num) when is_number(num) do
    num
  end

  def number_parse(numstr) do
    number_parse(numstr |> String.trim(), :integer)
  end
end

defmodule BulmaWidgets.Utils.Time do
  require Logger

  @minute_period 15
  @time_fmt "hh:mm a"

  def generate_times() do
    dt = Time.utc_now()

    for h <- 0..23, m <- Enum.take_every(0..59, @minute_period), into: [] do
      time = %{dt | hour: h, minute: m}
      {:ok, tstr} = Cldr.DateTime.to_string(time, WebApp.Cldr, format: @time_fmt)
      {tstr, time}
    end

    # |> IO.inspect(label: :generate_times)
  end

  # def display_date_time(date) do
  # date |> Calendar.Strftime.strftime!("m/d H:M:S")
  # end
end
