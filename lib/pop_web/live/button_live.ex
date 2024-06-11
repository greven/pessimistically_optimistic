defmodule POPWeb.ButtonLive do
  use POPWeb, :live_view

  alias POPWeb.PageComponents

  @impl true
  def render(assigns) do
    ~H"""
    <PageComponents.page_nav />

    <.header>
      Simple Optimistic Update
      <:subtitle>
        This example demonstrates how to set a loading state on a simple button while waiting the server to update the state. This makes use of the built-in Phoenix LiveView CSS classes (in this using case TailwindCSS) to handle the loading state.
        <span class="font-medium">Reference:</span>
        <a
          href="https://hexdocs.pm/phoenix_live_view/bindings.html#loading-states-and-errors"
          class="text-red-500 underline"
          target="_blank"
        >
          Loading States and Errors
        </a>
      </:subtitle>
    </.header>

    <div class="mt-32 flex flex-col items-center justify-center gap-6">
      <div class="flex flex-col items-center justify-center gap-2">
        <div class="text-5xl font-mono font-medium"><%= @counter %></div>
        <div class="text-xs uppercase text-gray-500">Counter</div>
      </div>
      <.button phx-click="inc" class="min-w-[120px]">
        <div class={["hidden", @form[:throttling].value && "phx-click-loading:block"]}>
          <span class="animate-pulse">Loading</span>
          <.icon name="hero-arrow-path-mini" class="ml-1 w-4.5 h-4.5 text-gray-400 animate-spin" />
        </div>
        <div class={@form[:throttling].value && "phx-click-loading:hidden"}>
          Increment <.icon name="hero-plus-mini" class="ml-1 w-4.5 h-4.5 text-gray-400" />
        </div>
      </.button>
    </div>

    <div class="flex items-center justify-center">
      <.simple_form for={@form} container_class="mt-5 flex items-center gap-6" phx-change="change">
        <.input type="checkbox" field={@form[:throttling]} label="Throttling" />
      </.simple_form>
    </div>

    <PageComponents.navigation>
      <%!-- <:next to={~p"/simple"}>Advanced</:next> --%>
    </PageComponents.navigation>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(counter: 0)
      |> assign(form: to_form(%{"throttling" => true}))

    {:ok, socket}
  end

  @impl true
  def handle_event("change", params, socket) do
    socket = assign(socket, form: params_to_form(params))
    {:noreply, socket}
  end

  def handle_event("inc", _payload, socket) do
    throttling? = Map.get(socket.assigns.form.source, "throttling", false)

    if throttling?, do: POP.Helpers.slow_function()

    socket = update(socket, :counter, &(&1 + 1))

    {:noreply, socket}
  end

  defp params_to_form(params) do
    params
    |> Enum.map(fn
      {k, v} when is_binary(v) -> {k, String.to_existing_atom(v)}
      item -> item
    end)
    |> Map.new()
    |> to_form()
  end
end
