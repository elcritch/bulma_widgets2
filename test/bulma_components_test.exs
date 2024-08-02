defmodule BulmaWidgetsTest do
  use ExUnit.Case
  doctest BulmaWidgets
  doctest BulmaWidgets.Actions

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import BulmaWidgets.Elements

  test "greets the world" do
    # assert BulmaWidgets.hello() == :world
    assigns = %{}
    res = rendered_to_string(~H"""
      <.tags>
        <:tag> Primary </:tag>
        <:tag is-link> Link </:tag>
        <:tag> Success </:tag>
      </.tags>
    """)
    IO.puts("res: #{res}")
  end
end
