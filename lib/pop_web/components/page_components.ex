defmodule POPWeb.PageComponents do
  use Phoenix.Component

  use POPWeb, :verified_routes

  alias POPWeb.CoreComponents

  @doc false

  attr :class, :any, default: nil
  attr :rest, :global

  def home_links(assigns) do
    ~H"""
    <div class={[@class, "flex"]}>
      <div class="w-full sm:w-auto">
        <div class="grid grid-cols-1 gap-4 text-md leading-6 text-zinc-800 sm:grid-cols-3">
          <.home_link to="/button" icon="hero-play-circle">Button</.home_link>
          <.home_link to="/collection" icon="hero-square-3-stack-3d">Collection</.home_link>
          <.home_link to="/tasks" icon="hero-list-bullet">Tasks</.home_link>
        </div>
      </div>
    </div>
    """
  end

  @doc false

  attr :to, :string, required: true
  attr :icon, :string, default: "hero-hashtag-mini"

  slot :inner_block

  def home_link(assigns) do
    ~H"""
    <.link
      href={@to}
      class="group relative rounded-lg px-3 py-2 text-sm font-medium leading-6 text-zinc-900"
    >
      <span class="absolute inset-0 rounded-lg bg-zinc-50 transition group-hover:bg-zinc-100 sm:group-hover:scale-105">
      </span>

      <span class="relative flex items-center gap-2.5">
        <CoreComponents.icon name={@icon} class="w-4 h-4 text-red-500 group-hover:text-red-600" />
        <span><%= render_slot(@inner_block) %></span>
      </span>
    </.link>
    """
  end

  @doc false

  attr :rest, :global

  slot :prev do
    attr :to, :string
  end

  slot :next do
    attr :to, :string
  end

  def navigation(assigns) do
    ~H"""
    <div {@rest}>
      <div class="flex justify-between">
        <.nav_item to="/">
          <%= render_slot(@prev) %>
        </.nav_item>
      </div>
    </div>
    """
  end

  @doc false

  attr :to, :string, required: true
  attr :rest, :global

  slot :inner_block

  defp nav_item(assigns) do
    ~H"""
    <div {@rest}>
      <.link class="text-blue-500" navigate={@to}>
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc false

  def page_nav(assigns) do
    ~H"""
    <div class="flex justify-between">
      <CoreComponents.back navigate={~p"/"}>Home</CoreComponents.back>
      <.ping />
    </div>
    """
  end

  @doc false

  attr :legend, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def ping(assigns) do
    ~H"""
    <div class={["text-sm text-zinc-900", @class]}>
      <.live_component id="ping" module={POPWeb.PingLive} />
    </div>
    """
  end
end
