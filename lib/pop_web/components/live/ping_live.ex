defmodule POPWeb.PingLive do
  use POPWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center">
      <span class="relative flex h-2 w-2 mr-2">
        <span class={[
          "animate-ping absolute inline-flex h-full w-full rounded-full transition-colors opacity-75",
          ping_class(@ping)
        ]}>
        </span>
        <span class={[
          "relative inline-flex rounded-full h-2 w-2 transition-colors",
          ping_class(@ping)
        ]}>
        </span>
      </span>

      <div class="flex justify-center gap-1">
        <span class="text-sm">Ping:</span>
        <div id="ping" class="font-semibold">
          <span id="ping-value" class="font-mono" phx-hook="Ping"></span><span class="text-zinc-600">ms</span>
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

  defp ping_class(ping) do
    cond do
      ping < 100 -> "bg-green-500"
      ping < 200 -> "bg-yellow-500"
      ping < 500 -> "bg-red-500"
      ping < 2000 -> "bg-purple-500"
      true -> "bg-gray-500"
    end
  end
end
