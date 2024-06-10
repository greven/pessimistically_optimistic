defmodule POPWeb.TasksLive do
  use POPWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.back navigate={~p"/"}>Home</.back>

    <.header>
      Tasks List Optimistic Update
      <:subtitle>
        This example demonstrates...
      </:subtitle>
    </.header>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
