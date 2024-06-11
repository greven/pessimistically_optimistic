defmodule POPWeb.TasksLive do
  use POPWeb, :live_view

  alias POPWeb.PageComponents

  @impl true
  def render(assigns) do
    ~H"""
    <PageComponents.page_nav />

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
