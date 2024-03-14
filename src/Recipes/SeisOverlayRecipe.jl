"""
    seisoverlay(d; <keyword arguments>)
    seisoverlay!(ax, d; <keyword arguments>)

Recipe to plot time-space, overlay plot of 2D seismic data `d`.

# Arguments:
- `d::Matrix{<:AbstractFloat}`: 2D seismic data to be plotted.

# Keyword Arguments:
- `ox=0`: first point of x-axis.
- `dx=1`: increment of x-axis.
- `oy=0`: first point of y-axis.
- `dy=1`: increment of y-axis.

- `pclip=98`: percentile for determining clip.
- `vmin=nothing`: minimum value used in colormapping data.
- `vmax=nothing`: maximum value used in colormapping data.

- `wiggle_fill_color=:black`: color for filling the positive wiggles.
- `wiggle_line_color=:black`: color for wiggles' lines.
- `wiggle_trace_increment=1`: increment for wiggle traces.
- `xcur=1.2`: wiggle excursion in traces corresponding to clip.

- `cmap=:seismic`: the colormap to be used.

# Examples
```julia
julia> d = SeisLinearEvents();
julia> f, ax, ov = seisoverlay(d)
```
```julia
julia> d = SeisLinearEvents(); f = Figure(); ax = Axis(f)
julia> ov = seisoverlay!(ax, d)
```
"""
@recipe(SeisOverlay, d) do scene
    Attributes(
        trace_color = :black,
        trace_width = 0.7,

        ox = 0,
        dx = 1,

        oy = 0,
        dy = 1,

        xcur = 1,
        wiggle_trace_increment = 1,

        pclip = 98,
        vmin = nothing,
        vmax = nothing,

        x = (1, 500),
        y = (1, 100),

        cmap = :seismic
    )
end

function Makie.plot!(overlay::SeisOverlay{<:Tuple{AbstractMatrix{<:Real}}})

    # Clipping the negative values of the first wiggle
    clipped_d = copy(overlay.d[])
    clipped_d[:, 1] = max.(clipped_d[:, 1], 0)

    seisimage!(overlay, clipped_d, ox=overlay.ox[], dx=overlay.dx[], oy=overlay.oy[],
               dy=overlay.dy[],
               cmap=overlay.cmap[],
               vmin=overlay.vmin[],
               vmax=overlay.vmax[],
               pclip=overlay.pclip[])
    seiswiggle!(overlay, clipped_d, ox=overlay.ox[],  dx=overlay.dx[], oy=overlay.oy[],
                dy=overlay.dy[],
                xcur=overlay.xcur[],
                wiggle_trace_increment=overlay.wiggle_trace_increment[],
                trace_color=overlay.trace_color[],
                trace_width=overlay.trace_width[],
                fillbands=false)

    overlay
end

function Makie.extract_colormap(pl::Plot{seisoverlay, Tuple{Matrix{Float64}}})
    # Return the ColorMapping of the seisimage plot
    #   -  typeof(pl.plots[1]) = Plot{SeisMakie.seisimage, Tuple{Matrix{<:Real}}}
    #   -  typeof(pl.plots[1].plots[1]) = Image{Tuple{ClosedInterval{Float32}, ClosedInterval{Float32}, Matrix{Float32}}}
    return Makie.extract_colormap(pl.plots[1].plots[1])
end
