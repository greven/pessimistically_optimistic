defmodule POPWeb.PingLive do
  use POPWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="ping" class="flex justify-center items-center" phx-hook="Ping">
      <span class="relative flex h-2 w-2 mr-2">
        <span
          id="ping-animation"
          class="animate-ping absolute inline-flex h-full w-full rounded-full transition-colors opacity-75"
        >
        </span>
        <span id="ping-indicator" class="relative inline-flex rounded-full h-2 w-2 transition-colors">
        </span>
      </span>

      <div class="flex justify-center gap-1">
        <span class="text-sm">Ping:</span>
        <div class="font-semibold">
          <span id="ping-value" class="font-mono"></span><span class="text-zinc-600">ms</span>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [ping: nil]}
  end

  @impl true
  def handle_event("ping", %{"rtt" => ping}, socket) do
    {:noreply,
     socket
     |> assign(ping: ping)
     |> push_event("pong", %{})}
  end
end
