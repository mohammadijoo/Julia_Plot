# line.jl
#
# Requirements (run once in the Julia REPL):
#   import Pkg
#   Pkg.add(["Plots", "PythonPlot", "CSV", "DataFrames"])

using Random
using Statistics
using Plots

# Select Plots.jl backend
pythonplot()   # alternative: gr()

# Global defaults (applies to all figures)
default(dpi=300)

# CSV example dependencies
using CSV
using DataFrames
using Downloads

Random.seed!(42)

# Helper: convert GitHub "blob" links to "raw" links (so CSV tools can read the actual file)
function github_blob_to_raw(url::AbstractString)::String
    if occursin("github.com", url) && occursin("/blob/", url)
        url2 = replace(url, "https://github.com/" => "https://raw.githubusercontent.com/")
        url2 = replace(url2, "/blob/" => "/")
        return url2
    end
    return url
end

# 1) Multiple line plots on same axes
begin
    x = LinRange(0, 2π, 200)
    y = sin.(x)

    p1 = plot(
        x, y;
        label="sin(x)",
        linestyle=:solid,
        marker=:circle,
        xlabel="x",
        ylabel="y",
        title="Multiple line plots",
        dpi=300,
    )

    plot!(p1, x, -y; label="-sin(x)", linestyle=:dash, marker=:x)
    plot!(p1, x, x ./ π .- 1; label="x/π - 1", linestyle=:dot, marker=:star5)

    # A line with implicit x = 1:n
    plot!(p1, [1.0, 0.7, 0.4, 0.0, -0.4, -0.7, -1.0]; label="")

    # display(p1)
    savefig(p1, "line_1.png")
end

# 2) Plot from a collection of vectors
begin
    Y = Set([
        [16.0, 5.0, 9.0, 4.0],
        [2.0, 11.0, 7.0, 14.0],
        [3.0, 10.0, 6.0, 15.0],
        [13.0, 8.0, 12.0, 1.0],
    ])

    p2 = plot(; xlabel="x", ylabel="y", title="Multiple line plots (collection of vectors)", dpi=300)
    for v in Y
        plot!(p2, v; label="")
    end

    # display(p2)
    savefig(p2, "line_2.png")
end

# 3) Sin function line plots
begin
    x = LinRange(0, 2π, 200)
    y1 = sin.(x)
    y2 = sin.(x .- 0.25)
    y3 = sin.(x .- 0.5)

    p3 = plot(x, y1; label="sin(x)", xlabel="x", ylabel="y", title="Sin() function line plots", dpi=300)
    plot!(p3, x, y2; label="sin(x-0.25)", linestyle=:dash)
    plot!(p3, x, y3; label="sin(x-0.5)", linestyle=:dot)

    # display(p3)
    savefig(p3, "line_3.png")
end

# 4) Sin function line plots with markers
begin
    x = LinRange(0, 2π, 200)
    y1 = sin.(x)
    y2 = sin.(x .- 0.25)
    y3 = sin.(x .- 0.5)

    p4 = plot(
        x, y1;
        label="sin(x)",
        marker=:circle,
        xlabel="x",
        ylabel="y",
        title="Sin() function line plots with markers",
        dpi=300,
    )
    plot!(p4, x, y2; label="sin(x-0.25)", linestyle=:dash, marker=:circle)
    plot!(p4, x, y3; label="sin(x-0.5)", marker=:star5)

    # display(p4)
    savefig(p4, "line_4.png")
end

# 5) Simple tiled layout example (separate figure)
begin
    x = LinRange(0, 3, 300)
    y1 = sin.(5 .* x)
    y2 = sin.(15 .* x)

    p_top = plot(x, y1; label="", title="Top Plot", xlabel="x", ylabel="sin(5x)", dpi=300)
    p_bot = plot(x, y2; label="", title="Bottom Plot", xlabel="x", ylabel="sin(15x)", dpi=300)

    p5 = plot(p_top, p_bot; layout=(2, 1), dpi=300)
    # display(p5)
    savefig(p5, "line_5.png")
end

# 6) Last figure: 3x2 subplots in a SINGLE block, 6 subplots total
begin
    # Subplot (row 0, col 0): sin(x) with marker indices
    x_a = LinRange(0, 10, 100)
    y_a = sin.(x_a)
    idx = 1:5:length(x_a)

    p6a = plot(x_a, y_a; label="", title="", xlabel="", ylabel="", dpi=300)
    scatter!(p6a, x_a[idx], y_a[idx]; label="", marker=:circle)

    # Subplot (row 0, col 1): tan(sin(x)) - sin(tan(x))
    x_b = LinRange(-π, π, 20)
    y_b = tan.(sin.(x_b)) .- sin.(tan.(x_b))
    p6b = plot(
        x_b, y_b;
        label="",
        linestyle=:dash,
        marker=:square,
        linewidth=2,
        markersize=6,
        title="",
        xlabel="",
        ylabel="",
        dpi=300,
    )

    # Subplot (row 1, col 0): cos(5x)
    x_c = LinRange(0, 10, 150)
    y_c = cos.(5 .* x_c)
    p6c = plot(x_c, y_c; label="", title="2-D Line Plot", xlabel="x", ylabel="cos(5x)", dpi=300)

    # Subplot (row 1, col 1): time plot
    x_d = 0:30:180
    y_d = [0.8, 0.9, 0.1, 0.9, 0.6, 0.1, 0.3]
    tick_labels = ["00:00s", "30:00", "01:00", "01:30", "02:00", "02:30", "03:00"]
    p6d = plot(
        x_d, y_d;
        label="",
        title="Time Plot",
        xlabel="Time",
        ylabel="",
        ylim=(0, 1),
        xticks=(collect(x_d), tick_labels),
        dpi=300,
    )

    # Subplot (row 2, col 0): sin(5x)
    x_e = LinRange(0, 3, 250)
    y_e = sin.(5 .* x_e)
    p6e = plot(x_e, y_e; label="", title="sin(5x)", xlabel="x", ylabel="y", dpi=300)

    # Subplot (row 2, col 1): circle
    r = 2.0
    xc = 4.0
    yc = 3.0
    theta = LinRange(0, 2π, 400)
    x_f = r .* cos.(theta) .+ xc
    y_f = r .* sin.(theta) .+ yc
    p6f = plot(x_f, y_f; label="", title="", xlabel="", ylabel="", aspect_ratio=:equal, dpi=300)

    p6 = plot(p6a, p6b, p6c, p6d, p6e, p6f; layout=(3, 2), size=(1200, 900), dpi=300)
    # display(p6)
    savefig(p6, "line_6.png")
end

# 7) Plot from a real-world CSV file (URL download)
begin
    csv_url = github_blob_to_raw("https://github.com/mohammadijoo/Datasets/blob/main/iris.csv")

    # If the CSV is on your local drive, you can read it like this:
    # df = CSV.read("C:/path/to/iris.csv", DataFrame)

    local_file = Downloads.download(csv_url)
    df = CSV.read(local_file, DataFrame)

    numcols = [c for c in names(df) if Base.nonmissingtype(eltype(df[!, c])) <: Real]
    @assert length(numcols) >= 2 "CSV must contain at least two numeric columns to plot."

    xcol, ycol = numcols[1], numcols[2]
    x = collect(skipmissing(df[!, xcol]))
    y = collect(skipmissing(df[!, ycol]))
    n = min(length(x), length(y))
    x, y = x[1:n], y[1:n]

    order = sortperm(x)

    p_csv = scatter(
        x[order], y[order];
        label="",
        xlabel=string(xcol),
        ylabel=string(ycol),
        title="Plot from CSV dataset",
        dpi=300,
    )
    plot!(p_csv, x[order], y[order]; label="", linestyle=:solid, dpi=300)

    # display(p_csv)
    savefig(p_csv, "line_csv.png")
end
