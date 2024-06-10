defmodule POP.Helpers do
  def slow_function(range \\ 200..1000) do
    Enum.random(range)
    |> Process.sleep()
  end
end
